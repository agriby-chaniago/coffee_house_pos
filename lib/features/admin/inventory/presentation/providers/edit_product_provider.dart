import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coffee_house_pos/core/config/appwrite_config.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';
import 'package:coffee_house_pos/core/services/offline_sync_manager.dart';
import 'package:coffee_house_pos/core/models/offline_queue_item_model.dart';
import 'package:coffee_house_pos/core/utils/error_handler.dart';
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
          print('✅ New image uploaded successfully');
          print('   File ID: ${file.$id}');
          print('   Image URL: $imageUrl');

          // Clean up temp file to prevent memory leak
          try {
            if (await newImageFile.exists()) {
              await newImageFile.delete();
              print('🗑️ Temp image file cleaned up');
            }
          } catch (e) {
            print('⚠️ Failed to clean up temp file: $e');
          }
        } catch (e) {
          print('⚠️ Image upload failed: $e');
          print('   Keeping existing image URL...');

          // Clean up temp file even on upload failure
          try {
            if (await newImageFile.exists()) {
              await newImageFile.delete();
              print('🗑️ Temp image file cleaned up (after failed upload)');
            }
          } catch (cleanupError) {
            print('⚠️ Failed to clean up temp file: $cleanupError');
          }
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

      // Try to update with offline support
      try {
        await appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollection,
          documentId: productId,
          data: updateData,
        );
        print('✅ Product updated successfully!');
      } catch (updateError) {
        print('⚠️ Offline - Queuing product update');
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.update,
          collectionName: AppwriteConfig.productsCollection,
          data: {'documentId': productId, ...updateData},
        );
        print('📥 Product update queued for sync when online');
      }

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

      final userMessage = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: userMessage,
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

  Future<bool> deleteProduct({
    required String productId,
    String? imageUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('🗑️ DELETING PRODUCT');
      print('═══════════════════════════════════════════════════════');
      print('Product ID: $productId');

      // Delete product image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // Extract file ID from URL
          // URL format: .../files/{fileId}/view?project=...
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final fileIdIndex = pathSegments.indexOf('files') + 1;

          if (fileIdIndex < pathSegments.length) {
            final fileId = pathSegments[fileIdIndex];
            print('📸 Deleting image file: $fileId');

            await appwrite.storage.deleteFile(
              bucketId: AppwriteConfig.productImagesBucket,
              fileId: fileId,
            );
            print('✅ Image deleted successfully');
          }
        } catch (e) {
          print('⚠️ Failed to delete image: $e');
          // Continue with product deletion even if image deletion fails
        }
      }

      // Delete product document (with offline support)
      print('🔄 Deleting product document from AppWrite...');
      try {
        await appwrite.databases.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollection,
          documentId: productId,
        );
        print('✅ Product deleted successfully!');
      } catch (deleteError) {
        print('⚠️ Offline - Queuing product deletion');
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.delete,
          collectionName: AppwriteConfig.productsCollection,
          data: {'documentId': productId},
        );
        print('📥 Product deletion queued for sync when online');
      }

      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR DELETING PRODUCT');
      print('═══════════════════════════════════════════════════════');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('═══════════════════════════════════════════════════════');

      final userMessage = ErrorHandler.getUserFriendlyMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: userMessage,
      );
      return false;
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
