import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import '../../../../core/services/appwrite_service.dart';
import '../../../../core/config/appwrite_config.dart';

class AuthRepository {
  final AppwriteService _appwriteService;

  AuthRepository(this._appwriteService);

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      print('=== Starting Google OAuth ===');
      print('Endpoint: ${AppwriteConfig.endpoint}');
      print('Project ID: ${AppwriteConfig.projectId}');
      print('Success URL: ${AppwriteConfig.successUrl}');
      print('Failure URL: ${AppwriteConfig.failureUrl}');

      await _appwriteService.account.createOAuth2Session(
        provider: OAuthProvider.google,
        success: AppwriteConfig.successUrl,
        failure: AppwriteConfig.failureUrl,
      );

      print('=== OAuth session created successfully ===');
    } on AppwriteException catch (e) {
      print('=== AppwriteException ===');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Response: ${e.response}');
      throw _handleAppwriteException(e);
    } catch (e) {
      print('=== Unknown Error ===');
      print('Error: $e');
      rethrow;
    }
  }

  /// Sign in with Email and Password
  Future<models.Session> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _appwriteService.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Sign up with Email and Password
  Future<models.User> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await _appwriteService.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Get current authenticated user
  Future<models.User?> getCurrentUser() async {
    try {
      return await _appwriteService.account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null; // Not authenticated
      }
      throw _handleAppwriteException(e);
    }
  }

  /// Get current session
  Future<models.Session?> getCurrentSession() async {
    try {
      return await _appwriteService.account.getSession(
        sessionId: 'current',
      );
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null;
      }
      throw _handleAppwriteException(e);
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = await _appwriteService.account.get();
      return user.emailVerification;
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _appwriteService.account.createVerification(
        url: '${AppwriteConfig.successUrl}/verify',
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Verify email with secret
  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await _appwriteService.account.updateVerification(
        userId: userId,
        secret: secret,
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _appwriteService.account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _appwriteService.account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Get user role from preferences
  Future<String?> getUserRole() async {
    try {
      final prefs = await _appwriteService.account.getPrefs();
      return prefs.data['role'] as String?;
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Set user role in preferences
  Future<void> setUserRole(String role) async {
    try {
      await _appwriteService.account.updatePrefs(
        prefs: {'role': role},
      );
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Handle AppWrite exceptions
  String _handleAppwriteException(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Unauthorized. Please login again.';
      case 409:
        return 'User already exists.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
