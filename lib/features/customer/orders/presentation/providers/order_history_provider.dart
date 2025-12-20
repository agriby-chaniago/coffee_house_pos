import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

/// Fetch user's order history
final orderHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final appwrite = ref.watch(appwriteProvider);
    final authState = ref.watch(authStateProvider);

    // Get current user ID
    String? userId;
    authState.whenData((state) {
      if (state is AuthStateAuthenticated) {
        userId = state.user.$id;
      }
    });

    if (userId == null) {
      print('⚠️ No authenticated user, returning empty orders');
      return [];
    }

    // Try load from Hive cache first - use singleton box
    Box box;
    try {
      box = Hive.box('order_history');
    } catch (e) {
      // Box not opened yet, open it
      box = await Hive.openBox('order_history');
    }

    final cachedData = box.get(userId);

    if (cachedData != null && cachedData is List) {
      // Return cached data immediately
      _fetchAndCacheOrders(appwrite, userId!, box);
      return List<Map<String, dynamic>>.from(
          cachedData.map((e) => Map<String, dynamic>.from(e as Map)));
    }

    // No cache, fetch from AppWrite
    return await _fetchAndCacheOrders(appwrite, userId!, box);
  } catch (e) {
    print('❌ Error loading order history: $e');
    return [];
  }
});

Future<List<Map<String, dynamic>>> _fetchAndCacheOrders(
  AppwriteService appwrite,
  String userId,
  Box box,
) async {
  try {
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      queries: [
        Query.equal('customerId', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(50), // Last 50 orders
      ],
    );

    final orders = response.documents.map((doc) => doc.data).toList();

    print('✅ Fetched ${orders.length} orders for user $userId');

    // Save to cache
    await box.put(userId, orders);

    return orders;
  } catch (e) {
    print('❌ Error fetching orders: $e');
    return [];
  }
}

/// Filter provider for order status
final orderHistoryFilterProvider = StateProvider<String>((ref) => 'all');

/// Search provider for order number
final orderHistorySearchProvider = StateProvider<String>((ref) => '');

/// Filtered order history
final filteredOrderHistoryProvider =
    Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final ordersAsync = ref.watch(orderHistoryProvider);
  final filter = ref.watch(orderHistoryFilterProvider);
  final search = ref.watch(orderHistorySearchProvider).toLowerCase();

  return ordersAsync.when(
    data: (orders) {
      var filtered = orders;

      // Filter by status
      if (filter != 'all') {
        filtered = filtered.where((order) {
          final status = order['status'] as String? ?? '';
          return status == filter;
        }).toList();
      }

      // Search by order number
      if (search.isNotEmpty) {
        filtered = filtered.where((order) {
          final orderNumber =
              (order['orderNumber'] as String? ?? '').toLowerCase();
          return orderNumber.contains(search);
        }).toList();
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
