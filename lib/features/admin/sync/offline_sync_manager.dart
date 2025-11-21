import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/appwrite_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/config/appwrite_config.dart';
import '../../customer/orders/data/models/order_model.dart';

/// Manages synchronization of offline orders to AppWrite when online
class OfflineSyncManager {
  final AppwriteService _appwrite;
  Timer? _syncTimer;
  bool _isSyncing = false;

  OfflineSyncManager(this._appwrite);

  /// Start periodic sync every 5 minutes
  void startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncPendingOrders(),
    );
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manually trigger sync of pending orders
  Future<SyncResult> syncPendingOrders() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;

    try {
      // Get all pending orders from offline queue
      final box = HiveService.getOrdersBox();
      final unsyncedOrders = box.values
          .map((json) => Order.fromJson(Map<String, dynamic>.from(json)))
          .where((o) => !o.isSynced)
          .toList();

      if (unsyncedOrders.isEmpty) {
        _isSyncing = false;
        return SyncResult(
          success: true,
          syncedCount: 0,
          failedCount: 0,
          message: 'No pending orders to sync',
        );
      }

      int syncedCount = 0;
      int failedCount = 0;
      final List<String> errors = [];

      for (final order in unsyncedOrders) {
        try {
          // Upload to AppWrite
          final response = await _appwrite.databases.createDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.ordersCollection,
            documentId: order.id ??
                order.orderNumber, // Use offline order ID or order number
            data: order.toJson(),
          );

          // Update order with AppWrite ID and mark as synced
          final syncedOrder = order.copyWith(
            id: response.$id,
            isSynced: true,
          );

          final box = HiveService.getOrdersBox();
          await box.put(syncedOrder.id, syncedOrder.toJson());
          syncedCount++;
        } catch (e) {
          failedCount++;
          errors.add('Order ${order.orderNumber}: $e');
          print('Failed to sync order ${order.orderNumber}: $e');
        }
      }

      _isSyncing = false;

      return SyncResult(
        success: failedCount == 0,
        syncedCount: syncedCount,
        failedCount: failedCount,
        message: failedCount == 0
            ? 'Successfully synced $syncedCount orders'
            : 'Synced $syncedCount orders, $failedCount failed',
        errors: errors.isEmpty ? null : errors,
      );
    } catch (e) {
      _isSyncing = false;
      return SyncResult(
        success: false,
        syncedCount: 0,
        failedCount: 0,
        message: 'Sync failed: $e',
        errors: [e.toString()],
      );
    }
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Dispose resources
  void dispose() {
    stopPeriodicSync();
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;
  final List<String>? errors;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.message,
    this.errors,
  });
}

// Provider for offline sync manager
final offlineSyncManagerProvider = Provider<OfflineSyncManager>((ref) {
  final appwrite = ref.watch(appwriteProvider);
  final manager = OfflineSyncManager(appwrite);

  // Start periodic sync
  manager.startPeriodicSync();

  // Cleanup on dispose
  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});

// Provider to manually trigger sync
final syncNowProvider = FutureProvider.autoDispose<SyncResult>((ref) async {
  final manager = ref.watch(offlineSyncManagerProvider);
  return await manager.syncPendingOrders();
});

// Provider to check sync status
final isSyncingProvider = Provider<bool>((ref) {
  final manager = ref.watch(offlineSyncManagerProvider);
  return manager.isSyncing;
});
