import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../../../core/services/appwrite_service.dart';
import '../../../../core/config/appwrite_config.dart';

class AuthRepository {
  final AppwriteService _appwriteService;

  AuthRepository(this._appwriteService);

  /// Sign in with Email and Password
  Future<models.Session> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _appwriteService.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Ensure user document exists in database
      await _ensureUserDocument();

      return session;
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
      // Create account
      final user = await _appwriteService.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create user document in database (only for customers, not admins)
      // Admins are identified by @coffee.com email and stored only in Auth
      if (!email.endsWith('@coffee.com')) {
        try {
          print('🔄 Creating customer document for: $email');
          print('   Database ID: ${AppwriteConfig.databaseId}');
          print('   Collection ID: ${AppwriteConfig.usersCollection}');
          print('   Document ID: ${user.$id}');

          await _appwriteService.databases.createDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollection,
            documentId: user.$id,
            data: {
              'userId': user.$id,
              'email': email,
              'name': name,
              'phone': '',
              'photoUrl': '',
            },
          );
          print('✅ Customer document created in database');
        } catch (e) {
          print('❌ ERROR creating user document: $e');
          print('   Error type: ${e.runtimeType}');
          if (e is AppwriteException) {
            print('   Code: ${e.code}');
            print('   Message: ${e.message}');
            print('   Response: ${e.response}');
          }
          // Don't throw - account was created successfully in Auth
        }
      } else {
        print('✅ Admin account created (Auth only, no database document)');
      }

      return user;
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
        url: 'https://your-app-url.com/verify',
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

  /// Get user role based on email domain
  /// @coffee.com emails are admins, others are customers
  Future<String?> getUserRole() async {
    try {
      final user = await _appwriteService.account.get();
      if (user.email.endsWith('@coffee.com')) {
        return 'admin';
      } else {
        return 'customer';
      }
    } on AppwriteException catch (e) {
      throw _handleAppwriteException(e);
    }
  }

  /// Ensure user document exists in database (only for customers, not admins)
  Future<void> _ensureUserDocument() async {
    try {
      final user = await _appwriteService.account.get();

      // Skip for admin accounts (@coffee.com)
      if (user.email.endsWith('@coffee.com')) {
        print('✅ Admin account - no database document needed');
        return;
      }

      // Try to get user document
      try {
        await _appwriteService.databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollection,
          documentId: user.$id,
        );
        print('✅ Customer document already exists');
      } catch (e) {
        // Document doesn't exist, create it
        if (e.toString().contains('404')) {
          print('⚠️ Customer document not found, creating one...');
          print('🔄 Database ID: ${AppwriteConfig.databaseId}');
          print('🔄 Collection ID: ${AppwriteConfig.usersCollection}');
          print('🔄 Document ID: ${user.$id}');

          try {
            await _appwriteService.databases.createDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.usersCollection,
              documentId: user.$id,
              data: {
                'userId': user.$id,
                'email': user.email,
                'name': user.name,
                'phone': '',
                'photoUrl': '',
              },
            );
            print('✅ Customer document created in database');
          } catch (createError) {
            print('❌ ERROR creating document: $createError');
            if (createError is AppwriteException) {
              print('   Code: ${createError.code}');
              print('   Message: ${createError.message}');
              print('   Response: ${createError.response}');
            }
          }
        } else {
          print('❌ Error checking user document: $e');
        }
      }
    } catch (e) {
      print('⚠️ Error ensuring user document: $e');
      // Don't throw - this is non-critical
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
