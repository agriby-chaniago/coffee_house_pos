import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';

/// Orders filter model
class OrdersFilter {
  final String? status; // null = All
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final String searchQuery;

  OrdersFilter({
    this.status,
    this.startDate,
    this.endDate,
    this.paymentMethod,
    this.searchQuery = '',
  });

  OrdersFilter copyWith({
    String? Function()? status,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    String? Function()? paymentMethod,
    String? searchQuery,
  }) {
    return OrdersFilter(
      status: status != null ? status() : this.status,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      paymentMethod:
          paymentMethod != null ? paymentMethod() : this.paymentMethod,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Orders filter notifier
class OrdersFilterNotifier extends StateNotifier<OrdersFilter> {
  OrdersFilterNotifier() : super(OrdersFilter());

  void setStatus(String? status) {
    state = state.copyWith(status: () => status);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: () => start,
      endDate: () => end,
    );
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(paymentMethod: () => method);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = OrdersFilter();
  }
}

/// Orders filter provider
final ordersFilterProvider =
    StateNotifierProvider<OrdersFilterNotifier, OrdersFilter>((ref) {
  return OrdersFilterNotifier();
});

/// Fetch all orders from AppWrite
final allOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  // Watch filter to trigger refetch when filter changes
  ref.watch(ordersFilterProvider);

  try {
    print('═══════════════════════════════════════════════════════');
    print('📋 FETCHING ALL ORDERS');
    print('═══════════════════════════════════════════════════════');

    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      queries: [
        Query.orderDesc('\$createdAt'),
        Query.limit(100), // Pagination can be added later
      ],
    );

    final orders = response.documents.map((doc) {
      return Order.fromJson({...doc.data, '\$id': doc.$id});
    }).toList();

    print('✅ Fetched ${orders.length} orders');
    print('═══════════════════════════════════════════════════════');

    return orders;
  } catch (e, stackTrace) {
    print('❌ ERROR FETCHING ORDERS: $e');
    print('Stack: $stackTrace');
    throw Exception('Failed to fetch orders: $e');
  }
});

/// Filtered orders based on current filter state
final filteredOrdersProvider =
    Provider.autoDispose<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(allOrdersProvider);
  final filter = ref.watch(ordersFilterProvider);

  return ordersAsync.whenData((orders) {
    var filtered = orders;

    // Filter by status
    if (filter.status != null && filter.status!.toLowerCase() != 'all') {
      filtered = filtered
          .where((o) => o.status.toLowerCase() == filter.status!.toLowerCase())
          .toList();
    }

    // Filter by date range
    if (filter.startDate != null && filter.endDate != null) {
      filtered = filtered.where((o) {
        return o.createdAt.isAfter(filter.startDate!) &&
            o.createdAt.isBefore(filter.endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by payment method
    if (filter.paymentMethod != null &&
        filter.paymentMethod!.toLowerCase() != 'all') {
      filtered = filtered
          .where((o) =>
              o.paymentMethod?.toLowerCase() ==
              filter.paymentMethod!.toLowerCase())
          .toList();
    }

    // Search by order number or customer name
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.orderNumber.toLowerCase().contains(query) ||
            (o.customerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  });
});

/// Orders statistics
class OrdersStats {
  final int totalOrders;
  final int pendingCount;
  final int preparingCount;
  final int readyCount;
  final int completedCount;
  final int cancelledCount;

  OrdersStats({
    required this.totalOrders,
    required this.pendingCount,
    required this.preparingCount,
    required this.readyCount,
    required this.completedCount,
    required this.cancelledCount,
  });
}

/// Orders statistics provider
final ordersStatsProvider = Provider.autoDispose<OrdersStats>((ref) {
  final ordersAsync = ref.watch(allOrdersProvider);

  return ordersAsync.when(
    data: (orders) {
      return OrdersStats(
        totalOrders: orders.length,
        pendingCount:
            orders.where((o) => o.status.toLowerCase() == 'pending').length,
        preparingCount:
            orders.where((o) => o.status.toLowerCase() == 'preparing').length,
        readyCount:
            orders.where((o) => o.status.toLowerCase() == 'ready').length,
        completedCount:
            orders.where((o) => o.status.toLowerCase() == 'completed').length,
        cancelledCount:
            orders.where((o) => o.status.toLowerCase() == 'cancelled').length,
      );
    },
    loading: () => OrdersStats(
      totalOrders: 0,
      pendingCount: 0,
      preparingCount: 0,
      readyCount: 0,
      completedCount: 0,
      cancelledCount: 0,
    ),
    error: (_, __) => OrdersStats(
      totalOrders: 0,
      pendingCount: 0,
      preparingCount: 0,
      readyCount: 0,
      completedCount: 0,
      cancelledCount: 0,
    ),
  );
});

/// Single order by ID provider
final orderByIdProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, orderId) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    print('📋 Fetching order: $orderId');

    final doc = await appwrite.databases.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      documentId: orderId,
    );

    return Order.fromJson({...doc.data, '\$id': doc.$id});
  } catch (e) {
    print('❌ ERROR FETCHING ORDER: $e');
    throw Exception('Failed to fetch order: $e');
  }
});
