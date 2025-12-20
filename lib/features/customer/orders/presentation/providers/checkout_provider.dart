import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/customer_cart_provider.dart';

enum CheckoutStatus { idle, loading, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? orderId;
  final String? errorMessage;

  CheckoutState({
    required this.status,
    this.orderId,
    this.errorMessage,
  });

  factory CheckoutState.initial() => CheckoutState(status: CheckoutStatus.idle);

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? orderId,
    String? errorMessage,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(CheckoutState.initial());

  Future<void> placeOrder({
    required String customerName,
    required String tableNumber,
    required String paymentMethod,
    String? notes,
  }) async {
    state = state.copyWith(status: CheckoutStatus.loading);

    try {
      final appwrite = ref.read(appwriteProvider);
      final cartState = ref.read(customerCartProvider);
      final authState = ref.read(authStateProvider);

      if (cartState.items.isEmpty) {
        throw Exception('Keranjang kosong');
      }

      // Get current user ID
      String? customerId;
      authState.whenData((state) {
        if (state is AuthStateAuthenticated) {
          customerId = state.user.$id;
        }
      });

      if (customerId == null) {
        throw Exception('User belum login');
      }

      // Prepare order items with correct field names matching OrderItem model
      final orderItems = cartState.items.map((item) {
        return {
          'id':
              '${item.productId}_${DateTime.now().millisecondsSinceEpoch}', // Generate unique ID
          'productId': item.productId,
          'productName': item.productName,
          'selectedSize': item.size, // Changed from 'size' to 'selectedSize'
          'basePrice': item.price, // Changed from 'price' to 'basePrice'
          'quantity': item.quantity,
          'addOns': item.addons // Changed from 'addons' to 'addOns'
              .map((a) => {
                    'id': a.id,
                    'name': a.name,
                    'additionalPrice': a
                        .additionalPrice, // Changed from 'price' to 'additionalPrice'
                  })
              .toList(),
          'notes': item.notes,
        };
      }).toList();

      // Generate order number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final orderNumber = 'ORD-$timestamp';

      // Encode items as JSON string (AppWrite schema requires string type)
      final itemsJson = json.encode(orderItems);

      // Combine table number with notes
      final fullNotes = tableNumber.isNotEmpty
          ? 'Meja: $tableNumber${notes != null && notes.isNotEmpty ? '\n$notes' : ''}'
          : notes ?? '';

      // Create order document matching AppWrite schema
      final orderData = {
        'orderNumber': orderNumber,
        'customerId': customerId,
        'customerName': customerName,
        'items': itemsJson,
        'subtotal': cartState.subtotal,
        'taxAmount': cartState.tax,
        'taxRate': 11.0, // PPN 11%
        'total': cartState.total,
        'status': 'pending',
        'paymentMethod': paymentMethod,
        'cashierId': 'customer-app',
        // Note: cashierName should be added to Appwrite schema
        // For now, we rely on cashierId to identify self orders
        'notes': fullNotes,
      };

      print('📊 Order data to send:');
      print('  - orderNumber: $orderNumber');
      print('  - subtotal: ${cartState.subtotal}');
      print('  - taxAmount: ${cartState.tax}');
      print('  - total: ${cartState.total}');

      print('📝 Creating order with data: $orderData');

      final response = await appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollection,
        documentId: 'unique()',
        data: orderData,
      );

      print('✅ Order created successfully!');
      print('   - Order ID: ${response.$id}');
      print('   - Created At: ${response.$createdAt}');
      print('   - Customer ID: $customerId');
      print('   - Order Number: $orderNumber');
      print('   - Total: ${cartState.total}');
      print('   - Status: pending');
      print('   - Payment Method: $paymentMethod');

      // Clear cart after successful order
      ref.read(customerCartProvider.notifier).clearCart();

      state = state.copyWith(
        status: CheckoutStatus.success,
        orderId: response.$id,
      );
    } catch (e) {
      String errorMsg = e.toString();

      // Better error messages for common issues
      if (errorMsg.contains('401')) {
        errorMsg =
            'Gagal membuat pesanan. Pastikan permissions di AppWrite sudah dikonfigurasi dengan benar untuk collection "orders".';
      } else if (errorMsg.contains('404')) {
        errorMsg = 'Collection "orders" tidak ditemukan di database AppWrite.';
      } else if (errorMsg.contains('network')) {
        errorMsg = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      }

      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: errorMsg,
      );

      print('❌ Checkout error: $e');
    }
  }

  void reset() {
    state = CheckoutState.initial();
  }
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
