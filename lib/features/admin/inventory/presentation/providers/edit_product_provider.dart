import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_variant_model.dart';
import 'package:appwrite/appwrite.dart';

class EditProductState {
  final bool isLoading;
  final bool success;
  final String? error;

  EditProductState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  EditProductState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return EditProductState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

class EditProductNotifier extends StateNotifier<EditProductState> {
  final Ref ref;

  EditProductNotifier(this.ref) : super(EditProductState());

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String category,
    String? existingImageUrl,
    File? newImageFile,
    required double priceM,
    required double stockUsageM,
    required double priceL,
    required double stockUsageL,
    required String stockUnit,
    required double minStock,
    required bool isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('✏️ UPDATING PRODUCT: $name');
      print('═══════════════════════════════════════════════════════');

      // Handle image
      String imageUrl = existingImageUrl ?? '';
      if (newImageFile != null) {
        print('📸 Uploading new image...');
        try {
          final file = await appwrite.storage.createFile(
            bucketId: AppwriteConfig.productImagesBucket,
            fileId: ID.unique(),
            file: InputFile.fromPath(
              path: newImageFile.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );

          imageUrl =
              '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.productImagesBucket}/files/${file.$id}/view?project=${AppwriteConfig.projectId}';
          print('✅ New image uploaded: ${file.$id}');
        } catch (e) {
          print('⚠️ Image upload failed: $e');
          print('   Keeping existing image URL...');
        }
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
      print('  ID: $productId');
      print('  Name: $name');
      print('  Category: $category');
      print('  Image URL: ${imageUrl.isEmpty ? "(empty)" : imageUrl}');
      print('  Is Active: $isActive');

      // Create temporary product to encode variants properly
      final tempProduct = Product(
        id: productId,
        name: name,
        description: description,
        category: category,
        imageUrl: imageUrl,
        variants: variants,
        availableAddOnIds: [],
        stockUnit: stockUnit,
        currentStock: 0,
        minStock: minStock,
        isActive: isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Prepare update data
      final updateData = {
        'name': name,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'variants': tempProduct.toJson()['variants'],
        'stockUnit': stockUnit,
        'minStock': minStock,
        'isActive': isActive,
      };

      print('-----------------------------------------------------------');
      print('🔄 Updating product document in AppWrite...');

      await appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollection,
        documentId: productId,
        data: updateData,
      );

      print('✅ Product updated successfully!');
      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR UPDATING PRODUCT');
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
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void reset() {
    state = EditProductState();
  }
}

final editProductProvider =
    StateNotifierProvider<EditProductNotifier, EditProductState>((ref) {
  return EditProductNotifier(ref);
});
