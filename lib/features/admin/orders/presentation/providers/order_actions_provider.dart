import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/core/services/offline_sync_manager.dart';
import 'package:coffee_house_pos/core/models/offline_queue_item_model.dart';

part 'order_actions_provider.freezed.dart';

/// Order action state
@freezed
class OrderActionState with _$OrderActionState {
  const factory OrderActionState.idle() = _Idle;
  const factory OrderActionState.loading() = _Loading;
  const factory OrderActionState.success(String message) = _Success;
  const factory OrderActionState.error(String message) = _Error;
}

/// Order actions notifier
class OrderActionsNotifier extends StateNotifier<OrderActionState> {
  final AppwriteService _appwrite;

  OrderActionsNotifier(this._appwrite) : super(const OrderActionState.idle());

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    state = const OrderActionState.loading();

    try {
      print('═══════════════════════════════════════════════════════');
      print('🔄 UPDATING ORDER STATUS');
      print('Order ID: $orderId');
      print('New Status: $newStatus');
      print('═══════════════════════════════════════════════════════');

      final data = <String, dynamic>{
        'status': newStatus,
      };

      // Add completedAt timestamp if status is completed
      if (newStatus.toLowerCase() == 'completed') {
        data['completedAt'] = DateTime.now().toIso8601String();
      }

      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollection,
          documentId: orderId,
          data: data,
        );

        print('✅ Order status updated successfully');
        print('═══════════════════════════════════════════════════════');

        state = OrderActionState.success(
          'Order updated to ${_formatStatus(newStatus)}',
        );
      } catch (syncError) {
        print('⚠️ Offline or sync failed - Queuing order status update');
        print('Error: $syncError');

        // Queue for offline sync
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.update,
          collectionName: AppwriteConfig.ordersCollection,
          data: {'documentId': orderId, ...data},
        );

        print('📥 Order status update queued for sync when online');
        print('═══════════════════════════════════════════════════════');

        state = const OrderActionState.success(
          'Order updated (will sync when online)',
        );
      }
    } catch (e) {
      print('❌ UNKNOWN ERROR: $e');
      state = OrderActionState.error('Failed to update order: $e');
    }
  }

  /// Cancel order with reason
  Future<void> cancelOrder(String orderId, String reason) async {
    state = const OrderActionState.loading();

    try {
      print('═══════════════════════════════════════════════════════');
      print('❌ CANCELLING ORDER');
      print('Order ID: $orderId');
      print('Reason: $reason');
      print('═══════════════════════════════════════════════════════');

      final data = {
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
        'cancellationReason': reason,
      };

      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollection,
          documentId: orderId,
          data: data,
        );

        print('✅ Order cancelled successfully');
        print('═══════════════════════════════════════════════════════');

        state = const OrderActionState.success('Order cancelled successfully');
      } catch (syncError) {
        print('⚠️ Offline or sync failed - Queuing order cancellation');
        print('Error: $syncError');

        // Queue for offline sync
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.update,
          collectionName: AppwriteConfig.ordersCollection,
          data: {'documentId': orderId, ...data},
        );

        print('📥 Order cancellation queued for sync when online');
        print('═══════════════════════════════════════════════════════');

        state = const OrderActionState.success(
          'Order cancelled (will sync when online)',
        );
      }
    } catch (e) {
      print('❌ UNKNOWN ERROR: $e');
      state = OrderActionState.error('Failed to cancel order: $e');
    }
  }

  /// Reset state to idle
  void reset() {
    state = const OrderActionState.idle();
  }

  /// Format status for display
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

/// Order actions provider
final orderActionsProvider =
    StateNotifierProvider<OrderActionsNotifier, OrderActionState>((ref) {
  final appwrite = ref.watch(appwriteProvider);
  return OrderActionsNotifier(appwrite);
});
