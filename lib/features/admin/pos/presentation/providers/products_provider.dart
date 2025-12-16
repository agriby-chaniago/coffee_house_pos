import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/services/hive_service.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../customer/menu/data/models/product_model.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final appwrite = ref.watch(appwriteProvider);

  try {
    // Try to fetch from AppWrite first
    print('Fetching products from AppWrite...');
    print('Database ID: ${AppwriteConfig.databaseId}');
    print('Collection ID: ${AppwriteConfig.productsCollection}');

    final response = await appwrite.databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollection,
    );

    print(
        'Successfully fetched ${response.documents.length} products from AppWrite');

    final products = <Product>[];
    for (var i = 0; i < response.documents.length; i++) {
      try {
        final doc = response.documents[i];
        print('Parsing product ${i + 1}: ${doc.data['name']}');
        final product = Product.fromJson(doc.data);
        products.add(product);
      } catch (e, stackTrace) {
        print('Error parsing product ${i + 1}: $e');
        print('Product data: ${response.documents[i].data}');
        print('Stack trace: $stackTrace');
        // Continue parsing other products
      }
    }

    print('Successfully parsed ${products.length} products');

    // Cache to Hive for offline use
    final box = HiveService.getProductsBox();
    for (final product in products) {
      await box.put(product.id, product.toJson());
    }

    return products;
  } catch (e) {
    // Log detailed error
    print('Failed to fetch products from AppWrite: $e');
    print('Error type: ${e.runtimeType}');

    // Try to get from Hive cache
    final box = HiveService.getProductsBox();
    if (box.isNotEmpty) {
      print('Loading ${box.length} products from Hive cache');
      final cachedProducts = box.values
          .map((json) => Product.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cachedProducts;
    }

    // No cache available, throw user-friendly error
    print('No cached products found.');
    print('');
    print('=== TROUBLESHOOTING ===');
    print('1. Check if database "coffee_house_db" exists in AppWrite Console');
    print('2. Check if collection "products" exists in the database');
    print(
        '3. Verify Project ID in appwrite_config.dart: ${AppwriteConfig.projectId}');
    print('4. Check AppWrite Console > Database > Copy Database ID');
    print('=======================');

    final userMessage = ErrorHandler.getUserFriendlyMessage(e);
    throw Exception(userMessage);
  }
});

final productsByCategoryProvider =
    Provider.family<List<Product>, String>((ref, category) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    data: (products) {
      if (category == 'All') return products;
      return products.where((p) => p.category == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final productCategoriesProvider = Provider<List<String>>((ref) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    data: (products) {
      final categories = products.map((p) => p.category).toSet().toList();
      return ['All', ...categories];
    },
    loading: () => ['All'],
    error: (_, __) => ['All'],
  );
});

final searchedProductsProvider =
    Provider.family<List<Product>, String>((ref, query) {
  final productsAsync = ref.watch(productsProvider);

  return productsAsync.when(
    data: (products) {
      if (query.isEmpty) return products;

      final lowerQuery = query.toLowerCase();
      return products.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
