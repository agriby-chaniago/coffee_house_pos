import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as models;
import '../../../../core/services/appwrite_service.dart';
import '../../data/repositories/auth_repository.dart';

/// Provider for AppWrite service
final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  final service = AppwriteService();
  service.initialize();
  return service;
});

/// Provider for auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final appwriteService = ref.watch(appwriteServiceProvider);
  return AuthRepository(appwriteService);
});

/// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final authRepository = ref.watch(authRepositoryProvider);

  // Initial state check
  try {
    final user = await authRepository.getCurrentUser();
    if (user == null) {
      yield const AuthState.unauthenticated();
      return;
    }

    final role = await authRepository.getUserRole();

    // Skip email verification check for development
    // if (!user.emailVerification) {
    //   yield AuthState.unverified(user);
    //   return;
    // }

    yield AuthState.authenticated(user, role);
  } catch (e) {
    yield AuthState.error(e.toString());
  }
});

/// Current user provider
final currentUserProvider = FutureProvider<models.User?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentUser();
});

/// Auth state sealed class
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(models.User user, String? role) =
      AuthStateAuthenticated;
  const factory AuthState.unverified(models.User user) = AuthStateUnverified;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final models.User user;
  final String? role;

  const AuthStateAuthenticated(this.user, this.role);

  bool get isAdmin => role?.toLowerCase() == 'admin';
  bool get isCustomer => role?.toLowerCase() == 'customer';
}

class AuthStateUnverified extends AuthState {
  final models.User user;

  const AuthStateUnverified(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;

  const AuthStateError(this.message);
}

/// Auth notifier for auth actions
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      // Role is automatically determined by email domain (@coffee.com = admin, others = customer)
      // No need to set role manually

      // Refresh auth state
      _ref.invalidate(authStateProvider);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Auto sign in after sign up
      await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      // Role is automatically determined by email domain (@coffee.com = admin, others = customer)
      // No need to set role manually

      // Refresh auth state
      _ref.invalidate(authStateProvider);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.sendEmailVerification();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signOut();

      // Refresh auth state
      _ref.invalidate(authStateProvider);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
