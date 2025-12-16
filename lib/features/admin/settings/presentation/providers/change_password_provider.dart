import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/services/appwrite_service.dart';

class ChangePasswordState {
  final bool isLoading;
  final bool success;
  final String? error;

  ChangePasswordState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  ChangePasswordState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final Ref ref;

  ChangePasswordNotifier(this.ref) : super(ChangePasswordState());

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('═══════════════════════════════════════════════════════');
      print('🔒 CHANGING PASSWORD');
      print('═══════════════════════════════════════════════════════');

      final appwrite = ref.read(appwriteProvider);

      await appwrite.account.updatePassword(
        password: newPassword,
        oldPassword: currentPassword,
      );

      print('✅ Password changed successfully');
      print('═══════════════════════════════════════════════════════');

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR CHANGING PASSWORD');
      print('═══════════════════════════════════════════════════════');
      print('Error: $e');
      print('═══════════════════════════════════════════════════════');

      String errorMessage = 'Failed to change password';
      if (e.toString().contains('user_invalid_credentials')) {
        errorMessage = 'Current password is incorrect';
      } else if (e.toString().contains('password')) {
        errorMessage = 'New password does not meet requirements';
      } else if (e.toString().contains('unauthorized') ||
          e.toString().contains('401')) {
        errorMessage = 'Session expired. Please login again';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  void reset() {
    state = ChangePasswordState();
  }
}

final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier(ref);
});
