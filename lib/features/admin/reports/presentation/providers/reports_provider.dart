import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';

enum DateRangeFilter {
  today,
  week,
  month,
  custom,
}

class ReportsFilter {
  final DateRangeFilter rangeType;
  final DateTime startDate;
  final DateTime endDate;

  ReportsFilter({
    required this.rangeType,
    required this.startDate,
    required this.endDate,
  });

  factory ReportsFilter.today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return ReportsFilter(
      rangeType: DateRangeFilter.today,
      startDate: start,
      endDate: end,
    );
  }

  factory ReportsFilter.week() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return ReportsFilter(
      rangeType: DateRangeFilter.week,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory ReportsFilter.month() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return ReportsFilter(
      rangeType: DateRangeFilter.month,
      startDate: start,
      endDate: end,
    );
  }

  factory ReportsFilter.custom(DateTime start, DateTime end) {
    // Limit to 30 days max
    final maxEnd = start.add(const Duration(days: 30));
    final actualEnd = end.isAfter(maxEnd) ? maxEnd : end;

    return ReportsFilter(
      rangeType: DateRangeFilter.custom,
      startDate: DateTime(start.year, start.month, start.day),
      endDate:
          DateTime(actualEnd.year, actualEnd.month, actualEnd.day, 23, 59, 59),
    );
  }

  ReportsFilter copyWith({
    DateRangeFilter? rangeType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportsFilter(
      rangeType: rangeType ?? this.rangeType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ReportsFilterNotifier extends StateNotifier<ReportsFilter> {
  ReportsFilterNotifier() : super(ReportsFilter.today());

  void setToday() {
    state = ReportsFilter.today();
  }

  void setWeek() {
    state = ReportsFilter.week();
  }

  void setMonth() {
    state = ReportsFilter.month();
  }

  void setCustom(DateTime start, DateTime end) {
    state = ReportsFilter.custom(start, end);
  }
}

final reportsFilterProvider =
    StateNotifierProvider<ReportsFilterNotifier, ReportsFilter>((ref) {
  return ReportsFilterNotifier();
});

// Fetch orders for current period
final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final filter = ref.watch(reportsFilterProvider);
  final appwrite = ref.watch(appwriteProvider);

  try {
    print('═══════════════════════════════════════════════════════');
    print('📊 FETCHING ORDERS FOR REPORTS');
    print('═══════════════════════════════════════════════════════');
    print('Date Range: ${filter.startDate} to ${filter.endDate}');

    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      queries: [
        Query.greaterThanEqual(
            '\$createdAt', filter.startDate.toIso8601String()),
        Query.lessThanEqual('\$createdAt', filter.endDate.toIso8601String()),
        Query.orderDesc('\$createdAt'),
        Query.limit(1000),
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

// Fetch orders for previous period (for comparison)
final previousOrdersProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final filter = ref.watch(reportsFilterProvider);
  final appwrite = ref.watch(appwriteProvider);

  // Calculate previous period
  final duration = filter.endDate.difference(filter.startDate);
  final prevEnd = filter.startDate.subtract(const Duration(seconds: 1));
  final prevStart = prevEnd.subtract(duration);

  try {
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollection,
      queries: [
        Query.greaterThanEqual('\$createdAt', prevStart.toIso8601String()),
        Query.lessThanEqual('\$createdAt', prevEnd.toIso8601String()),
        Query.limit(1000),
      ],
    );

    return response.documents.map((doc) {
      return Order.fromJson({...doc.data, '\$id': doc.$id});
    }).toList();
  } catch (e) {
    print('⚠️ Failed to fetch previous period orders: $e');
    return [];
  }
});

class ReportsMetrics {
  final double totalRevenue;
  final int orderCount;
  final double averageOrderValue;
  final double revenueChange;
  final double orderCountChange;
  final double avgOrderValueChange;

  ReportsMetrics({
    required this.totalRevenue,
    required this.orderCount,
    required this.averageOrderValue,
    required this.revenueChange,
    required this.orderCountChange,
    required this.avgOrderValueChange,
  });
}

final reportsMetricsProvider =
    FutureProvider.autoDispose<ReportsMetrics>((ref) async {
  final orders = await ref.watch(ordersProvider.future);
  final previousOrders = await ref.watch(previousOrdersProvider.future);

  // Current period metrics
  final totalRevenue =
      orders.fold<double>(0, (sum, order) => sum + order.total);
  final orderCount = orders.length;
  final averageOrderValue =
      orderCount > 0 ? (totalRevenue / orderCount).toDouble() : 0.0;

  // Previous period metrics
  final prevRevenue =
      previousOrders.fold<double>(0, (sum, order) => sum + order.total);
  final prevOrderCount = previousOrders.length;
  final prevAvgOrderValue =
      prevOrderCount > 0 ? (prevRevenue / prevOrderCount).toDouble() : 0.0;

  // Calculate percentage changes
  double revenueChange = 0;
  if (prevRevenue > 0) {
    revenueChange = ((totalRevenue - prevRevenue) / prevRevenue) * 100;
  }

  double orderCountChange = 0;
  if (prevOrderCount > 0) {
    orderCountChange = ((orderCount - prevOrderCount) / prevOrderCount) * 100;
  }

  double avgOrderValueChange = 0;
  if (prevAvgOrderValue > 0) {
    avgOrderValueChange =
        ((averageOrderValue - prevAvgOrderValue) / prevAvgOrderValue) * 100;
  }

  return ReportsMetrics(
    totalRevenue: totalRevenue,
    orderCount: orderCount,
    averageOrderValue: averageOrderValue,
    revenueChange: revenueChange,
    orderCountChange: orderCountChange,
    avgOrderValueChange: avgOrderValueChange,
  );
});

class ProductSales {
  final String productId;
  final String productName;
  final int quantity;
  final double revenue;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
  });
}

final topProductsProvider =
    FutureProvider.autoDispose<List<ProductSales>>((ref) async {
  final orders = await ref.watch(ordersProvider.future);

  final Map<String, ProductSales> productMap = {};

  for (final order in orders) {
    for (final item in order.items) {
      if (productMap.containsKey(item.productId)) {
        final existing = productMap[item.productId]!;
        productMap[item.productId] = ProductSales(
          productId: item.productId,
          productName: item.productName,
          quantity: existing.quantity + item.quantity,
          revenue: existing.revenue + item.itemTotal,
        );
      } else {
        productMap[item.productId] = ProductSales(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          revenue: item.itemTotal,
        );
      }
    }
  }

  final sortedProducts = productMap.values.toList()
    ..sort((a, b) => b.quantity.compareTo(a.quantity));

  return sortedProducts.take(10).toList();
});

class CategorySales {
  final String category;
  final double revenue;
  final int orderCount;

  CategorySales({
    required this.category,
    required this.revenue,
    required this.orderCount,
  });
}

final categorySalesProvider =
    FutureProvider.autoDispose<List<CategorySales>>((ref) async {
  final orders = await ref.watch(ordersProvider.future);

  // We need to fetch products to get categories
  final appwrite = ref.watch(appwriteProvider);
  final productsResponse = await appwrite.databases.listDocuments(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.productsCollection,
  );

  final Map<String, String> productCategories = {};
  for (final doc in productsResponse.documents) {
    productCategories[doc.$id] = doc.data['category'] as String? ?? 'Unknown';
  }

  final Map<String, CategorySales> categoryMap = {};

  for (final order in orders) {
    for (final item in order.items) {
      final category = productCategories[item.productId] ?? 'Unknown';

      if (categoryMap.containsKey(category)) {
        final existing = categoryMap[category]!;
        categoryMap[category] = CategorySales(
          category: category,
          revenue: existing.revenue + item.itemTotal,
          orderCount: existing.orderCount + 1,
        );
      } else {
        categoryMap[category] = CategorySales(
          category: category,
          revenue: item.itemTotal,
          orderCount: 1,
        );
      }
    }
  }

  return categoryMap.values.toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
});

class HourlySales {
  final int hour;
  final int orderCount;
  final double revenue;

  HourlySales({
    required this.hour,
    required this.orderCount,
    required this.revenue,
  });
}

final hourlySalesProvider =
    FutureProvider.autoDispose<List<HourlySales>>((ref) async {
  final orders = await ref.watch(ordersProvider.future);

  final Map<int, HourlySales> hourlyMap = {};

  for (final order in orders) {
    final hour = order.createdAt.hour;

    if (hourlyMap.containsKey(hour)) {
      final existing = hourlyMap[hour]!;
      hourlyMap[hour] = HourlySales(
        hour: hour,
        orderCount: existing.orderCount + 1,
        revenue: existing.revenue + order.total,
      );
    } else {
      hourlyMap[hour] = HourlySales(
        hour: hour,
        orderCount: 1,
        revenue: order.total,
      );
    }
  }

  // Fill missing hours with 0
  final List<HourlySales> hourlySales = [];
  for (int i = 0; i < 24; i++) {
    hourlySales.add(
      hourlyMap[i] ?? HourlySales(hour: i, orderCount: 0, revenue: 0),
    );
  }

  return hourlySales;
});

class PaymentMethodSales {
  final String method;
  final int count;
  final double revenue;

  PaymentMethodSales({
    required this.method,
    required this.count,
    required this.revenue,
  });
}

final paymentMethodSalesProvider =
    FutureProvider.autoDispose<List<PaymentMethodSales>>((ref) async {
  final orders = await ref.watch(ordersProvider.future);

  final Map<String, PaymentMethodSales> methodMap = {};

  for (final order in orders) {
    final method = order.paymentMethod ?? 'Unknown';

    if (methodMap.containsKey(method)) {
      final existing = methodMap[method]!;
      methodMap[method] = PaymentMethodSales(
        method: method,
        count: existing.count + 1,
        revenue: existing.revenue + order.total,
      );
    } else {
      methodMap[method] = PaymentMethodSales(
        method: method,
        count: 1,
        revenue: order.total,
      );
    }
  }

  return methodMap.values.toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
});

class DailySales {
  final DateTime date;
  final double revenue;
  final int orderCount;

  DailySales({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });
}

final dailySalesProvider =
    FutureProvider.autoDispose<List<DailySales>>((ref) async {
  final orders = await ref.watch(ordersProvider.future);
  final filter = ref.watch(reportsFilterProvider);

  final Map<String, DailySales> dailyMap = {};

  for (final order in orders) {
    final dateKey = DateTime(
      order.createdAt.year,
      order.createdAt.month,
      order.createdAt.day,
    );
    final key = dateKey.toIso8601String().split('T')[0];

    if (dailyMap.containsKey(key)) {
      final existing = dailyMap[key]!;
      dailyMap[key] = DailySales(
        date: dateKey,
        revenue: existing.revenue + order.total,
        orderCount: existing.orderCount + 1,
      );
    } else {
      dailyMap[key] = DailySales(
        date: dateKey,
        revenue: order.total,
        orderCount: 1,
      );
    }
  }

  // Fill missing dates with 0
  final List<DailySales> dailySales = [];
  DateTime current = filter.startDate;
  while (current.isBefore(filter.endDate) ||
      current.isAtSameMomentAs(filter.endDate)) {
    final key = DateTime(current.year, current.month, current.day)
        .toIso8601String()
        .split('T')[0];

    dailySales.add(
      dailyMap[key] ??
          DailySales(
            date: DateTime(current.year, current.month, current.day),
            revenue: 0,
            orderCount: 0,
          ),
    );

    current = current.add(const Duration(days: 1));
  }

  return dailySales;
});

// Low stock products provider
final lowStockProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollection,
      queries: [
        Query.limit(100),
      ],
    );

    final products = response.documents.map((doc) {
      return Product.fromJson({...doc.data, '\$id': doc.$id});
    }).toList();

    // Filter low stock products
    return products
        .where((product) => product.currentStock <= product.minStock)
        .toList();
  } catch (e) {
    print('⚠️ Failed to fetch low stock products: $e');
    return [];
  }
});

// Waste summary provider
final wasteSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);
  final filter = ref.watch(reportsFilterProvider);

  try {
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.wasteLogsCollection,
      queries: [
        Query.greaterThanEqual('timestamp', filter.startDate.toIso8601String()),
        Query.lessThanEqual('timestamp', filter.endDate.toIso8601String()),
        Query.limit(1000),
      ],
    );

    final wasteLogs = response.documents.map((doc) {
      return {
        'amount': (doc.data['amount'] as num).toDouble(),
      };
    }).toList();

    final totalAmount = wasteLogs.fold<double>(
      0.0,
      (sum, log) => sum + (log['amount'] ?? 0.0),
    );

    return {
      'count': wasteLogs.length,
      'totalAmount': totalAmount,
    };
  } catch (e) {
    print('⚠️ Failed to fetch waste summary: $e');
    return {
      'count': 0,
      'totalAmount': 0.0,
    };
  }
});
