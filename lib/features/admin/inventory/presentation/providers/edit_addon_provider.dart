import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/services/offline_sync_manager.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/models/operation_type.dart';

class EditAddOnState {
  final bool isLoading;
  final String? error;
  final bool success;

  EditAddOnState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  EditAddOnState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return EditAddOnState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class EditAddOnNotifier extends StateNotifier<EditAddOnState> {
  final Ref ref;

  EditAddOnNotifier(this.ref) : super(EditAddOnState());

  Future<bool> updateAddOn({
    required String addOnId,
    required String name,
    required String category,
    required double additionalPrice,
    required bool isDefault,
    required int sortOrder,
    required bool isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('🔄 UPDATING ADD-ON');
      print('═══════════════════════════════════════════════════════');
      print('ID: $addOnId');
      print('Name: $name');
      print('Category: $category');
      print('Price: Rp ${additionalPrice.toStringAsFixed(0)}');
      print('Is Default: $isDefault');
      print('Sort Order: $sortOrder');
      print('Is Active: $isActive');
      print('═══════════════════════════════════════════════════════');

      final data = {
        'name': name,
        'category': category,
        'additionalPrice': additionalPrice,
        'isDefault': isDefault,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

      // Update add-on document (with offline support)
      try {
        await appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.addonsCollection,
          documentId: addOnId,
          data: data,
        );
        print('✅ Add-on updated successfully!');
      } catch (updateError) {
        print('⚠️ Offline - Queuing add-on update');
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.update,
          collectionName: AppwriteConfig.addonsCollection,
          data: {'documentId': addOnId, ...data},
        );
        print('📥 Add-on update queued for sync when online');
      }

      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR UPDATING ADD-ON');
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

  Future<bool> deleteAddOn({required String addOnId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('🗑️ DELETING ADD-ON');
      print('═══════════════════════════════════════════════════════');
      print('ID: $addOnId');
      print('═══════════════════════════════════════════════════════');

      // Delete add-on document (with offline support)
      try {
        await appwrite.databases.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.addonsCollection,
          documentId: addOnId,
        );
        print('✅ Add-on deleted successfully!');
      } catch (deleteError) {
        print('⚠️ Offline - Queuing add-on deletion');
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.delete,
          collectionName: AppwriteConfig.addonsCollection,
          data: {'documentId': addOnId},
        );
        print('📥 Add-on deletion queued for sync when online');
      }

      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR DELETING ADD-ON');
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
    state = EditAddOnState();
  }
}

final editAddOnProvider =
    StateNotifierProvider<EditAddOnNotifier, EditAddOnState>((ref) {
  return EditAddOnNotifier(ref);
});
