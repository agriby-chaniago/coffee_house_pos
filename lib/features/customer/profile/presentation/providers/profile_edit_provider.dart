import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/config/appwrite_config.dart';

class ProfileEditState {
  final bool isLoading;
  final String? error;
  final bool success;

  ProfileEditState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProfileEditState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ProfileEditState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final Ref ref;

  ProfileEditNotifier(this.ref) : super(ProfileEditState());

  Future<File?> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate file size (max 2MB for profile photo)
        final fileSize = await file.length();
        const maxSizeInBytes = 2 * 1024 * 1024; // 2MB

        if (fileSize > maxSizeInBytes) {
          state = state.copyWith(
            error: 'Image size exceeds 2MB. Please choose a smaller image.',
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

  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? phone,
    File? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final appwrite = ref.read(appwriteProvider);
      String? imageUrl;

      // Upload profile image if provided
      if (profileImage != null) {
        imageUrl = await _uploadProfileImage(appwrite, userId, profileImage);
        if (imageUrl == null) {
          throw Exception('Failed to upload profile image');
        }
      }

      // Update display name using Account API (this is the proper way)
      if (displayName != null) {
        try {
          await appwrite.account.updateName(name: displayName);
          print('✅ Display name updated via Account API');
        } catch (e) {
          print('❌ Error updating display name: $e');
          throw Exception('Failed to update display name: $e');
        }
      }

      // Update phone and photoUrl in user document (optional extended profile data)
      if (phone != null || imageUrl != null) {
        final updateData = <String, dynamic>{};
        if (phone != null) updateData['phone'] = phone;
        if (imageUrl != null) updateData['photoUrl'] = imageUrl;

        try {
          // Try to update existing document
          await appwrite.databases.updateDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollection,
            documentId: userId,
            data: updateData,
          );
          print('✅ Extended profile data updated');
        } catch (e) {
          // If document doesn't exist (404), create it
          if (e.toString().contains('404')) {
            print('⚠️ User document not found, creating new one');
            try {
              await appwrite.databases.createDocument(
                databaseId: AppwriteConfig.databaseId,
                collectionId: AppwriteConfig.usersCollection,
                documentId: userId,
                data: {
                  'userId': userId,
                  'email': '', // Will be filled by backend/trigger if needed
                  ...updateData,
                },
              );
              print('✅ User document created with extended data');
            } catch (createError) {
              print('❌ Error creating user document: $createError');
              // Don't throw here, name was already updated successfully
            }
          } else {
            print('❌ Error updating user document: $e');
            // Don't throw here, name was already updated successfully
          }
        }
      }

      state = state.copyWith(isLoading: false, success: true);
      print('✅ Profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<String?> _uploadProfileImage(
    AppwriteService appwrite,
    String userId,
    File imageFile,
  ) async {
    try {
      print('🔄 Starting profile image upload...');
      print('   Bucket ID: ${AppwriteConfig.profilePhotosBucket}');
      print('   User ID: $userId');
      print('   File path: ${imageFile.path}');

      final storage = Storage(appwrite.client);

      // Delete old profile image if exists (optional)
      // You can track this in user document

      // Upload new image
      print('📤 Uploading file to storage...');
      final file = await storage.createFile(
        bucketId: AppwriteConfig.profilePhotosBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: 'profile_$userId.jpg',
        ),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );

      print('✅ File uploaded successfully: ${file.$id}');

      // Get file view URL
      final fileUrl =
          '${appwrite.client.endPoint}/storage/buckets/${AppwriteConfig.profilePhotosBucket}/files/${file.$id}/view?project=${AppwriteConfig.projectId}';

      print('✅ Profile image uploaded: $fileUrl');
      return fileUrl;
    } catch (e) {
      print('❌ ERROR uploading profile image: $e');
      print('   Error type: ${e.runtimeType}');
      if (e is AppwriteException) {
        print('   Code: ${e.code}');
        print('   Message: ${e.message}');
        print('   Response: ${e.response}');
      }
      return null;
    }
  }

  // Change password method
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final appwrite = ref.read(appwriteProvider);
      final account = appwrite.account;

      // Update password using Appwrite Account API
      // This requires the current password for security
      await account.updatePassword(
        password: newPassword,
        oldPassword: currentPassword,
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = ProfileEditState();
  }
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(ref);
});
