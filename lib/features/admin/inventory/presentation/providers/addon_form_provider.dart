import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/config/appwrite_config.dart';
import '../../../../../core/services/appwrite_service.dart';
import '../../../../../core/services/offline_sync_manager.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/models/operation_type.dart';

class AddOnFormState {
  final bool isLoading;
  final String? error;
  final bool success;

  AddOnFormState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AddOnFormState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return AddOnFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class AddOnFormNotifier extends StateNotifier<AddOnFormState> {
  final Ref ref;

  AddOnFormNotifier(this.ref) : super(AddOnFormState());

  Future<bool> createAddOn({
    required String name,
    required String category,
    required double additionalPrice,
    required bool isDefault,
    required int sortOrder,
    bool isActive = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appwrite = ref.read(appwriteProvider);

      print('═══════════════════════════════════════════════════════');
      print('🔄 CREATING ADD-ON');
      print('═══════════════════════════════════════════════════════');
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

      // Create add-on document (with offline support)
      try {
        await appwrite.databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.addonsCollection,
          documentId: ID.unique(),
          data: data,
        );
        print('✅ Add-on created successfully!');
      } catch (createError) {
        print('⚠️ Offline - Queuing add-on creation');
        await OfflineSyncManager().queueOperation(
          operationType: OperationType.create,
          collectionName: AppwriteConfig.addonsCollection,
          data: data,
        );
        print('📥 Add-on creation queued for sync when online');
      }

      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR CREATING ADD-ON');
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
    state = AddOnFormState();
  }
}

final addOnFormProvider =
    StateNotifierProvider<AddOnFormNotifier, AddOnFormState>((ref) {
  return AddOnFormNotifier(ref);
});
