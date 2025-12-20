import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/core/services/hive_service.dart';
import 'package:coffee_house_pos/core/utils/error_handler.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'dart:convert';

/// Search query state
final menuSearchProvider = StateProvider<String>((ref) => '');

/// Category filter state
final menuCategoryProvider = StateProvider<String>((ref) => 'All');

/// Fetch all products from AppWrite with caching
final menuProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    print('═══════════════════════════════════════════════════════');
    print('📋 FETCHING MENU PRODUCTS (CUSTOMER)');
    print('═══════════════════════════════════════════════════════');

    // Try to load from Hive cache first
    final productsBox = HiveService.getProductsBox();
    final cachedProducts = <Product>[];

    for (var key in productsBox.keys) {
      try {
        final productJson = productsBox.get(key);
        if (productJson != null) {
          final productData = productJson is String
              ? jsonDecode(productJson)
              : Map<String, dynamic>.from(productJson as Map);
          cachedProducts.add(Product.fromJson(productData));
        }
      } catch (e) {
        print('⚠️ Error parsing cached product: $e');
        continue; // Skip this product and continue
      }
    }

    // Return cache if available (for instant display)
    if (cachedProducts.isNotEmpty) {
      print('✅ Loaded ${cachedProducts.length} products from cache');
    }

    // Fetch fresh data from AppWrite
    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollection,
      queries: [
        Query.equal('isActive', true), // Only active products
        Query.orderAsc('name'),
        Query.limit(100),
      ],
    );

    final products = response.documents.map((doc) {
      return Product.fromJson({...doc.data, '\$id': doc.$id});
    }).toList();

    print('✅ Fetched ${products.length} products from AppWrite');

    // Update Hive cache
    for (var product in products) {
      if (product.id != null) {
        await productsBox.put(product.id, jsonEncode(product.toJson()));
      }
    }

    print('✅ Cache updated');
    print('═══════════════════════════════════════════════════════');

    return products;
  } catch (e, stackTrace) {
    print('❌ ERROR FETCHING MENU: $e');
    print('Stack: $stackTrace');

    // If error and we have cache, return cache
    final productsBox = HiveService.getProductsBox();
    if (productsBox.isNotEmpty) {
      print('⚠️ Using cached products due to error');
      final cachedProducts = <Product>[];
      for (var key in productsBox.keys) {
        try {
          final productJson = productsBox.get(key);
          if (productJson != null) {
            final productData = productJson is String
                ? jsonDecode(productJson)
                : Map<String, dynamic>.from(productJson as Map);
            cachedProducts.add(Product.fromJson(productData));
          }
        } catch (e) {
          print('⚠️ Error parsing cached product: $e');
          continue; // Skip this product and continue
        }
      }
      return cachedProducts;
    }

    final userMessage = ErrorHandler.getUserFriendlyMessage(e);
    throw Exception(userMessage);
  }
});

/// Filtered menu based on search and category
final filteredMenuProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final menuAsync = ref.watch(menuProvider);
  final searchQuery = ref.watch(menuSearchProvider);
  final category = ref.watch(menuCategoryProvider);

  return menuAsync.whenData((products) {
    var filtered = products;

    // Filter by category
    if (category != 'All') {
      filtered = filtered
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  });
});

/// Get category color
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'coffee':
      return const Color(0xFFDF8E1D); // Peach
    case 'non-coffee':
      return const Color(0xFFCBA6F7); // Mauve
    case 'food':
      return const Color(0xFF94E2D5); // Teal
    case 'dessert':
      return const Color(0xFFF5C2E7); // Pink
    default:
      return const Color(0xFF9399B2); // Grey
  }
}
