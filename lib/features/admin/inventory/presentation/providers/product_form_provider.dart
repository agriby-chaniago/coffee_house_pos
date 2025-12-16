import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_variant_model.dart';
import 'package:appwrite/appwrite.dart';

class ProductFormState {
  final bool isLoading;
  final bool success;
  final String? error;

  ProductFormState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  ProductFormState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Ref ref;

  ProductFormNotifier(this.ref) : super(ProductFormState());

  Future<bool> createProduct({
    required String name,
    required String description,
    required String category,
    File? imageFile,
    required double priceM,
    required double stockUsageM,
    required double priceL,
    required double stockUsageL,
    required String stockUnit,
    required double initialStock,
    required double minStock,
    required List<String> availableAddOnIds,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('📦 CREATING PRODUCT: $name');
      print('═══════════════════════════════════════════════════════');

      // Upload image if provided, otherwise use empty string
      String imageUrl = '';
      if (imageFile != null) {
        print('📸 Uploading image...');
        try {
          final file = await appwrite.storage.createFile(
            bucketId: AppwriteConfig.productImagesBucket,
            fileId: ID.unique(),
            file: InputFile.fromPath(
              path: imageFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );

          imageUrl =
              '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.productImagesBucket}/files/${file.$id}/view?project=${AppwriteConfig.projectId}';
          print('✅ Image uploaded: ${file.$id}');
        } catch (e) {
          print('⚠️ Image upload failed: $e');
          print('   Continuing with empty image URL...');
        }
      } else {
        print('ℹ️ No image provided, using empty string');
      }

      // Create variants
      final variants = [
        ProductVariant(
          size: 'M',
          price: priceM,
          stockUsagePerUnit: stockUsageM,
        ),
        ProductVariant(
          size: 'L',
          price: priceL,
          stockUsagePerUnit: stockUsageL,
        ),
      ];

      print('-----------------------------------------------------------');
      print('Product details:');
      print('  Name: $name');
      print('  Category: $category');
      print('  Image URL: ${imageUrl.isEmpty ? "(empty)" : imageUrl}');
      print('  Variants: ${variants.length}');
      print('  Stock Unit: $stockUnit');
      print('  Initial Stock: $initialStock');
      print('  Min Stock: $minStock');

      // Create product
      final product = Product(
        name: name,
        description: description,
        category: category,
        imageUrl: imageUrl,
        variants: variants,
        availableAddOnIds: availableAddOnIds,
        stockUnit: stockUnit,
        currentStock: initialStock,
        minStock: minStock,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('-----------------------------------------------------------');
      print('🔄 Creating product document in AppWrite...');

      // Prepare data without createdAt/updatedAt (AppWrite auto-generates these)
      final productData = {
        'name': name,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'variants': product.toJson()['variants'],
        'availableAddOnIds': product.toJson()['availableAddOnIds'],
        'stockUnit': stockUnit,
        'currentStock': initialStock,
        'minStock': minStock,
        'isActive': true,
      };

      print('Data to send:');
      productData.forEach((key, value) {
        print('  $key: $value');
      });

      await appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollection,
        documentId: ID.unique(),
        data: productData,
      );

      print('✅ Product created successfully!');
      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR CREATING PRODUCT');
      print('═══════════════════════════════════════════════════════');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

        if (fileSize > maxSizeInBytes) {
          state = state.copyWith(
            error: 'Image size exceeds 5MB. Please choose a smaller image.',
          );
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      state = state.copyWith(error: 'Failed to pick image: $e');
      return null;
    }
  }

  void reset() {
    state = ProductFormState();
  }
}

final productFormProvider =
    StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
  return ProductFormNotifier(ref);
});
