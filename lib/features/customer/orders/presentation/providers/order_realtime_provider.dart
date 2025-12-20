import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:async';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';

/// Real-time order status provider
/// Subscribes to AppWrite Realtime for order updates
final orderRealtimeProvider =
    StreamProvider.family<Map<String, dynamic>, String>(
  (ref, orderId) {
    final appwrite = ref.watch(appwriteProvider);

    final controller = StreamController<Map<String, dynamic>>();
    RealtimeSubscription? subscription;

    // Initial fetch
    _fetchOrder(appwrite, orderId).then((order) {
      if (!controller.isClosed) {
        controller.add(order);
      }
    });

    // Subscribe to real-time updates
    final realtime = Realtime(appwrite.client);
    subscription = realtime.subscribe([
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.ordersCollection}.documents.$orderId'
    ]);

    subscription.stream.listen(
      (event) {
        if (event.payload.isNotEmpty) {
          if (!controller.isClosed) {
            controller.add(event.payload);
          }
        }
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    ref.onDispose(() {
      subscription?.close();
      controller.close();
    });

    return controller.stream;
  },
);

Future<Map<String, dynamic>> _fetchOrder(
    AppwriteService appwrite, String orderId) async {
  try {
    final response = await appwrite.databases.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      documentId: orderId,
    );
    return response.data;
  } catch (e) {
    throw Exception('Failed to fetch order: $e');
  }
}

/// Helper to get order status color
const orderStatusColors = {
  'pending': 0xFF9399B2, // Grey
  'preparing': 0xFF89B4FA, // Blue
  'ready': 0xFFA6E3A1, // Green
  'completed': 0xFFDF8E1D, // Peach
  'cancelled': 0xFFF38BA8, // Red
};

/// Helper to get order status icon
const orderStatusIcons = {
  'pending': 'schedule',
  'preparing': 'restaurant',
  'ready': 'check_circle',
  'completed': 'done_all',
  'cancelled': 'cancel',
};

/// Helper to get estimated time for status
String getEstimatedTime(String status) {
  switch (status) {
    case 'pending':
      return 'Waiting for confirmation...';
    case 'preparing':
      return 'About 5-10 minutes';
    case 'ready':
      return 'Ready for pickup!';
    case 'completed':
      return 'Thank you!';
    case 'cancelled':
      return 'Order cancelled';
    default:
      return '';
  }
}
