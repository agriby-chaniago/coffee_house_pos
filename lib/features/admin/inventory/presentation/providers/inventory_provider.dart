import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';

final inventoryProductsProvider = FutureProvider<List<Product>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    print('Fetching products for inventory...');
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollection,
    );

    final products = <Product>[];
    for (var doc in response.documents) {
      try {
        final product = Product.fromJson(doc.data);
        products.add(product);
      } catch (e) {
        print('Error parsing product: $e');
      }
    }

    print('Fetched ${products.length} products for inventory');
    return products;
  } catch (e) {
    print('Error fetching products: $e');
    return [];
  }
});

// Filter and search state
class InventoryFilter {
  final String searchQuery;
  final String? categoryFilter;
  final bool showLowStockOnly;

  const InventoryFilter({
    this.searchQuery = '',
    this.categoryFilter,
    this.showLowStockOnly = false,
  });

  InventoryFilter copyWith({
    String? searchQuery,
    Object? categoryFilter = _sentinel,
    bool? showLowStockOnly,
  }) {
    return InventoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter == _sentinel ? this.categoryFilter : categoryFilter as String?,
      showLowStockOnly: showLowStockOnly ?? this.showLowStockOnly,
    );
  }
  
  static const _sentinel = Object();
}

class InventoryFilterNotifier extends StateNotifier<InventoryFilter> {
  InventoryFilterNotifier() : super(const InventoryFilter());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
  }

  void toggleLowStockFilter() {
    state = state.copyWith(showLowStockOnly: !state.showLowStockOnly);
  }

  void clearFilters() {
    state = const InventoryFilter();
  }
}

final inventoryFilterProvider =
    StateNotifierProvider<InventoryFilterNotifier, InventoryFilter>((ref) {
  return InventoryFilterNotifier();
});

// Filtered products provider
final filteredInventoryProductsProvider =
    Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(inventoryProductsProvider);
  final filter = ref.watch(inventoryFilterProvider);

  return productsAsync.whenData((products) {
    var filtered = products;

    // Apply search
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (filter.categoryFilter != null) {
      filtered =
          filtered.where((p) => p.category == filter.categoryFilter).toList();
    }

    // Apply low stock filter
    if (filter.showLowStockOnly) {
      filtered = filtered.where((p) => p.currentStock <= p.minStock).toList();
    }

    return filtered;
  });
});
