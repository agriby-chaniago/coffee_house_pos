import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/models/offline_queue_item_model.dart';
import 'package:coffee_house_pos/core/services/hive_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:uuid/uuid.dart';

class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;

  final Connectivity _connectivity = Connectivity();
  late final Databases _databases;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Status stream controller
  final _statusController = StreamController<void>.broadcast();
  Stream<void> get statusStream => _statusController.stream;

  bool _isSyncing = false;
  bool _isOnline = false;

  OfflineSyncManager._internal();

  // Connectivity status
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  // Get pending items count
  int getPendingCount() {
    final box = HiveService.getOfflineQueueBox();
    return box.length;
  }

  // Initialize sync manager
  Future<void> initialize(Databases databases) async {
    print('🔄 Initializing OfflineSyncManager...');

    // Set databases instance
    _databases = databases;

    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    print('📡 Initial connectivity: ${_isOnline ? "Online" : "Offline"}');
    _statusController.add(null); // Emit initial status

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOffline = !_isOnline;
        _isOnline = result != ConnectivityResult.none;
        print('📡 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
        _statusController.add(null); // Emit status change

        // If just came online, trigger sync
        if (wasOffline && _isOnline) {
          print('✅ Connection restored, triggering sync...');
          syncAll();
        }
      },
    );

    // Start periodic sync timer (every 30 seconds)
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isOnline && !_isSyncing) {
        syncAll();
      }
    });

    // Initial sync if online
    if (_isOnline) {
      syncAll();
    }

    print('✅ OfflineSyncManager initialized');
  }

  // Queue an operation for offline sync
  Future<void> queueOperation({
    required OperationType operationType,
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    final box = HiveService.getOfflineQueueBox();
    final queueItem = OfflineQueueItem(
      id: const Uuid().v4(),
      operationType: operationType,
      collectionName: collectionName,
      data: data,
      createdAt: DateTime.now(),
    );

    await box.put(queueItem.id, queueItem.toJson());
    print('📥 Queued ${operationType.name} operation for $collectionName');
    print('   Queue size: ${box.length}');
  }

  // Sync all queued operations
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏭️ Sync already in progress, skipping...');
      return;
    }

    if (!_isOnline) {
      print('📴 Offline, skipping sync');
      return;
    }

    final box = HiveService.getOfflineQueueBox();
    if (box.isEmpty) {
      print('✅ No pending operations to sync');
      return;
    }

    _isSyncing = true;
    print('═══════════════════════════════════════════════════════');
    print('🔄 STARTING OFFLINE SYNC');
    print('═══════════════════════════════════════════════════════');
    print('Pending operations: ${box.length}');

    final List<String> processedIds = [];
    final List<String> failedIds = [];

    // Process each queued item
    for (final key in box.keys) {
      try {
        final itemJson = box.get(key);
        final queueItem = OfflineQueueItem.fromJson(
          Map<String, dynamic>.from(itemJson as Map),
        );

        print('-----------------------------------------------------------');
        print(
            'Processing: ${queueItem.operationType.name} on ${queueItem.collectionName}');
        print('Item ID: ${queueItem.id}');
        print('Retry count: ${queueItem.retryCount}');

        if (!queueItem.canRetry) {
          print('❌ Max retries reached, removing from queue');
          processedIds.add(queueItem.id);
          continue;
        }

        try {
          await _processQueueItem(queueItem);
          processedIds.add(queueItem.id);
          print('✅ Successfully processed');
        } catch (e) {
          print('❌ Failed to process: $e');

          if (queueItem.canRetry) {
            // Update retry count
            final updatedItem = queueItem.incrementRetry(e.toString());
            await box.put(queueItem.id, updatedItem.toJson());
            print('🔄 Retry count updated: ${updatedItem.retryCount}/3');
            failedIds.add(queueItem.id);
          } else {
            // Max retries reached, remove
            processedIds.add(queueItem.id);
            print('❌ Max retries reached after this attempt');
          }
        }
      } catch (e) {
        print('❌ Error processing queue item: $e');
      }
    }

    // Remove successfully processed items
    for (final id in processedIds) {
      await box.delete(id);
    }

    print('═══════════════════════════════════════════════════════');
    print('✅ SYNC COMPLETED');
    print('Processed: ${processedIds.length}');
    print('Failed: ${failedIds.length}');
    print('Remaining: ${box.length}');
    print('═══════════════════════════════════════════════════════');

    _isSyncing = false;
    _statusController.add(null); // Emit status change after sync
  }

  // Process a single queue item
  Future<void> _processQueueItem(OfflineQueueItem item) async {
    switch (item.operationType) {
      case OperationType.create:
        await _processCreate(item);
        break;
      case OperationType.update:
        await _processUpdate(item);
        break;
      case OperationType.delete:
        await _processDelete(item);
        break;
    }
  }

  // Process CREATE operation
  Future<void> _processCreate(OfflineQueueItem item) async {
    print('Creating document in ${item.collectionName}...');

    final document = await _databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: item.collectionName,
      documentId: ID.unique(),
      data: item.data,
    );

    print('Document created: ${document.$id}');

    // If this is an order, mark it as synced in local Hive
    if (item.collectionName == AppwriteConfig.ordersCollection) {
      await _markOrderAsSynced(item.data['orderNumber'] as String);
    }
  }

  // Process UPDATE operation
  Future<void> _processUpdate(OfflineQueueItem item) async {
    print('Updating document in ${item.collectionName}...');

    final documentId = item.data['documentId'] as String;
    final updateData = Map<String, dynamic>.from(item.data);
    updateData.remove('documentId'); // Remove ID from data

    await _databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: item.collectionName,
      documentId: documentId,
      data: updateData,
    );

    print('Document updated: $documentId');
  }

  // Process DELETE operation
  Future<void> _processDelete(OfflineQueueItem item) async {
    print('Deleting document from ${item.collectionName}...');

    final documentId = item.data['documentId'] as String;

    await _databases.deleteDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: item.collectionName,
      documentId: documentId,
    );

    print('Document deleted: $documentId');
  }

  // Mark local order as synced
  Future<void> _markOrderAsSynced(String orderNumber) async {
    try {
      final ordersBox = HiveService.getOrdersBox();
      final orderJson = ordersBox.get(orderNumber);

      if (orderJson != null) {
        final orderData =
            jsonDecode(orderJson as String) as Map<String, dynamic>;
        orderData['isSynced'] = true;
        await ordersBox.put(orderNumber, jsonEncode(orderData));
        print('✅ Local order marked as synced: $orderNumber');
      }
    } catch (e) {
      print('⚠️ Failed to mark order as synced: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    print('🛑 OfflineSyncManager disposed');
  }
}
