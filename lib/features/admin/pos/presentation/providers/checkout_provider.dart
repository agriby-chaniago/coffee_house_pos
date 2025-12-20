import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import 'package:coffee_house_pos/core/services/hive_service.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/core/services/offline_sync_manager.dart';
import 'package:coffee_house_pos/core/models/offline_queue_item_model.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/utils/error_handler.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/admin/inventory/data/models/stock_movement_model.dart';
import 'package:coffee_house_pos/features/auth/presentation/providers/auth_provider.dart';
import 'cart_provider.dart';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';

class CheckoutState {
  final bool isLoading;
  final String? orderId;
  final Object? error;

  CheckoutState({
    this.isLoading = false,
    this.orderId,
    this.error,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? orderId,
    Object? error,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      orderId: orderId ?? this.orderId,
      error: error ?? this.error,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(CheckoutState());

  Future<bool> processCheckout({
    required PaymentMethod paymentMethod,
    String? customerName,
    double? cashReceived,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cart = ref.read(cartProvider);
      final authState = ref.read(authStateProvider).value;

      // Validate cart
      if (cart.items.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Validate cash payment
      if (paymentMethod == PaymentMethod.cash) {
        if (cashReceived == null) {
          throw Exception('Cash received amount is required for cash payment');
        }

        if (cashReceived < 0) {
          throw Exception('Cash received cannot be negative');
        }

        if (cashReceived < cart.total) {
          throw Exception(
              'Insufficient cash: received Rp ${cashReceived.toStringAsFixed(0)}, '
              'required Rp ${cart.total.toStringAsFixed(0)}');
        }

        // Check if cash received is reasonable (not absurdly large)
        const maxCashAmount = 100000000; // 100 million
        if (cashReceived > maxCashAmount) {
          throw Exception('Cash amount too large. Please verify the amount.');
        }
      }

      // Get current user info
      String cashierId = 'unknown';
      String cashierName = 'Unknown Cashier';

      if (authState is AuthStateAuthenticated) {
        cashierId = authState.user.$id;
        cashierName = authState.user.name;
      }

      // Generate order number: YYYYMMDD-###
      final orderNumber = await _generateOrderNumber();

      // Create order with pending status (will be updated as order is prepared)
      final now = DateTime.now();
      final order = Order(
        orderNumber: orderNumber,
        customerId: null,
        customerName: customerName,
        items: ref.read(cartProvider.notifier).toOrderItems(),
        subtotal: cart.subtotal,
        taxAmount: cart.taxAmount,
        taxRate: AppConstants.ppnRate,
        total: cart.total,
        status: OrderStatus.pending.name,
        paymentMethod: paymentMethod.name,
        cashierId: cashierId, // Will derive cashierName from getter
        createdAt: now,
        completedAt:
            null, // Will be set when order status is updated to completed
        updatedAt: now,
        isSynced: false,
      );

      // Save to Hive (local storage)
      await _saveOrderToHive(order);

      // Try to sync to AppWrite if online
      try {
        print('Attempting to sync order to AppWrite...');
        await _syncToAppwrite(order);
        print('Order synced successfully to AppWrite');

        // Deduct stock after successful sync
        print('📦 Deducting stock for order items...');
        await _deductStock(order, cashierId, cashierName);
        print('✅ Stock deduction completed');
      } catch (e) {
        // If sync fails, add to offline queue
        print('Failed to sync order to AppWrite: $e');
        print('Adding order to offline sync queue...');

        await OfflineSyncManager().queueOperation(
          operationType: OperationType.create,
          collectionName: AppwriteConfig.ordersCollection,
          data: order.toAppwriteJson(),
        );

        print('Order queued for offline sync');

        // Still try to deduct stock locally even if sync failed
        try {
          print('📦 Attempting local stock deduction...');
          await _deductStock(order, cashierId, cashierName);
          print('✅ Local stock deduction completed');
        } catch (stockError) {
          print('⚠️ Stock deduction failed: $stockError');
          // Log error but don't fail the checkout
        }
      }

      // Clear cart
      ref.read(cartProvider.notifier).clear();

      state = state.copyWith(
        isLoading: false,
        orderId: orderNumber,
      );

      return true;
    } catch (e) {
      final userMessage = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: userMessage,
      );
      return false;
    }
  }

  Future<String> _generateOrderNumber() async {
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Get daily counter from Hive
    final counterBox = HiveService.getDailyCounterBox();
    final today = datePrefix;
    final counter = (counterBox.get(today, defaultValue: 0) as int) + 1;

    // Save updated counter
    await counterBox.put(today, counter);

    return '$datePrefix-${counter.toString().padLeft(3, '0')}';
  }

  Future<void> _saveOrderToHive(Order order) async {
    final ordersBox = HiveService.getOrdersBox();

    // Store as JSON string
    final orderJson = jsonEncode(order.toJson());
    await ordersBox.put(order.orderNumber, orderJson);
  }

  Future<void> _syncToAppwrite(Order order) async {
    final appwrite = ref.read(appwriteProvider);

    try {
      print('═══════════════════════════════════════════════════════');
      print('🚀 SYNCING ORDER TO APPWRITE');
      print('═══════════════════════════════════════════════════════');
      print('Order Number: ${order.orderNumber}');
      print('Database ID: ${AppwriteConfig.databaseId}');
      print('Collection ID: ${AppwriteConfig.ordersCollection}');
      print('Project ID: ${AppwriteConfig.projectId}');
      print('Endpoint: ${AppwriteConfig.endpoint}');

      // Use toAppwriteJson() for proper format
      final orderData = order.toAppwriteJson();

      print('-----------------------------------------------------------');
      print('Order data BEFORE removing nulls:');
      orderData.forEach((key, value) {
        if (value == null) {
          print('  ❌ $key: NULL');
        } else {
          print(
              '  ✅ $key: ${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}...');
        }
      });

      // Remove null values
      orderData.removeWhere((key, value) => value == null);

      print('-----------------------------------------------------------');
      print('Order data AFTER removing nulls:');
      print('Keys: ${orderData.keys.toList()}');
      print('Number of items: ${order.items.length}');
      print('Total amount: ${order.total}');

      print('-----------------------------------------------------------');
      print('🔄 Creating document in AppWrite...');

      // Try to create document in AppWrite
      try {
        final document = await appwrite.databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollection,
          documentId: ID.unique(),
          data: orderData,
        );

        print('-----------------------------------------------------------');
        print('✅ SUCCESS! Document created with ID: ${document.$id}');
        print('═══════════════════════════════════════════════════════');

        // Mark as synced in local storage
        final syncedOrder = order.copyWith(isSynced: true);
        await _saveOrderToHive(syncedOrder);
      } catch (syncError) {
        print('-----------------------------------------------------------');
        print('⚠️ OFFLINE OR SYNC FAILED - Queuing for later');
        print('═══════════════════════════════════════════════════════');

        // Queue for offline sync
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.create,
          collectionName: AppwriteConfig.ordersCollection,
          data: orderData,
        );

        print('📥 Order queued for sync when online');
        print('═══════════════════════════════════════════════════════');

        // Save with isSynced = false
        await _saveOrderToHive(order);
      }
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR IN ORDER PROCESSING');
      print('═══════════════════════════════════════════════════════');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('-----------------------------------------------------------');
      print('Stack Trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════');
      // Let the error propagate to be caught by the caller
      rethrow;
    }
  }

  Future<void> _deductStock(
    Order order,
    String performedBy,
    String performedByName,
  ) async {
    final appwrite = ref.read(appwriteProvider);

    print('═══════════════════════════════════════════════════════');
    print('📦 STOCK DEDUCTION FOR ORDER: ${order.orderNumber}');
    print('═══════════════════════════════════════════════════════');

    for (final item in order.items) {
      try {
        print('-----------------------------------------------------------');
        print('Processing item: ${item.productName}');
        print('Product ID: ${item.productId}');
        print('Quantity: ${item.quantity}');
        print('Selected Size: ${item.selectedSize}');

        // Fetch product to get current stock and variant info
        final productDoc = await appwrite.databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollection,
          documentId: item.productId,
        );

        final product = Product.fromJson(productDoc.data);
        print('Current Stock: ${product.currentStock} ${product.stockUnit}');

        // Find the variant for the selected size
        final variant = product.variants.firstWhere(
          (v) => v.size == item.selectedSize,
          orElse: () => throw Exception(
              'Variant not found for size ${item.selectedSize}'),
        );

        print('Stock usage per unit: ${variant.stockUsagePerUnit}');

        // Calculate total stock to deduct
        final totalUsage = item.quantity * variant.stockUsagePerUnit;
        print('Total stock to deduct: $totalUsage ${product.stockUnit}');

        // Calculate new stock
        final newStock = product.currentStock - totalUsage;
        print('New stock will be: $newStock ${product.stockUnit}');

        if (newStock < 0) {
          print('⚠️ WARNING: Stock will go negative!');
        }

        // Update product stock in AppWrite (with offline support)
        try {
          await appwrite.databases.updateDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.productsCollection,
            documentId: item.productId,
            data: {
              'currentStock': newStock,
            },
          );
          print('✅ Product stock updated successfully');
        } catch (updateError) {
          print('⚠️ Offline - Queuing stock update');
          await OfflineSyncManager().queueOperation(
            operationType: OperationType.update,
            collectionName: AppwriteConfig.productsCollection,
            data: {
              'documentId': item.productId,
              'currentStock': newStock,
            },
          );
        }

        // Create stock movement log (with offline support)
        try {
          final movement = StockMovement(
            orderId: order.orderNumber,
            orderNumber: order.orderNumber,
            productId: item.productId,
            productName: item.productName,
            amount: totalUsage,
            stockUnit: product.stockUnit,
            type: 'sale',
            performedBy: performedBy,
            timestamp: DateTime.now(),
          );

          try {
            await appwrite.databases.createDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockMovementsCollection,
              documentId: ID.unique(),
              data: {
                'orderId': movement.orderId,
                'orderNumber': movement.orderNumber,
                'productId': movement.productId,
                'productName': movement.productName,
                'amount': movement.amount,
                'stockUnit': movement.stockUnit,
                'type': movement.type,
                'performedBy': movement.performedBy,
                'timestamp': movement.timestamp.toIso8601String(),
              },
            );
            print('✅ Stock movement logged');
          } catch (logError) {
            print('⚠️ Offline - Queuing stock movement log');
            await OfflineSyncManager().queueOperation(
              operationType: OperationType.create,
              collectionName: AppwriteConfig.stockMovementsCollection,
              data: {
                'orderId': movement.orderId,
                'orderNumber': movement.orderNumber,
                'productId': movement.productId,
                'productName': movement.productName,
                'amount': movement.amount,
                'stockUnit': movement.stockUnit,
                'type': movement.type,
                'performedBy': movement.performedBy,
                'timestamp': movement.timestamp.toIso8601String(),
              },
            );
          }
        } catch (logError) {
          print('⚠️ Failed to create stock movement log: $logError');
        }
      } catch (e, stackTrace) {
        print('-----------------------------------------------------------');
        print('❌ ERROR deducting stock for ${item.productName}');
        print('Error: $e');
        print('Stack Trace: $stackTrace');
        print('-----------------------------------------------------------');
        // Continue with other items even if one fails
      }
    }

    print('═══════════════════════════════════════════════════════');
    print('✅ STOCK DEDUCTION PROCESS COMPLETED');
    print('═══════════════════════════════════════════════════════');
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
