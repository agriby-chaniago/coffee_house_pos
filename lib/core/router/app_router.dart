import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/customer/menu/presentation/screens/menu_screen.dart';
import '../../features/customer/cart/presentation/screens/cart_screen.dart';
import '../../features/customer/orders/presentation/screens/checkout_screen.dart';
import '../../features/customer/orders/presentation/screens/order_history_screen.dart';
import '../../features/customer/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_screen.dart';
import '../../features/customer/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/customer/profile/presentation/screens/change_password_screen.dart';
import '../../features/customer/profile/presentation/screens/terms_conditions_screen.dart';
import '../../features/customer/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/customer/notifications/presentation/screens/notifications_screen.dart';
import '../../features/admin/pos/presentation/screens/pos_screen.dart';
import '../../features/admin/orders/presentation/screens/orders_screen.dart';
import '../../features/admin/orders/presentation/screens/order_detail_screen.dart';
import '../../features/admin/inventory/presentation/screens/inventory_screen.dart';
import '../../features/admin/inventory/presentation/screens/waste_logs_screen.dart';
import '../../features/admin/inventory/presentation/screens/addon_management_screen.dart';
import '../../features/admin/reports/presentation/screens/reports_screen.dart';
import '../../features/admin/settings/presentation/screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Enable debug logging
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isVerifyRoute = state.matchedLocation == '/verify-email';
      final isSplashRoute = state.matchedLocation == '/splash';
      final isTermsRoute =
          state.matchedLocation == '/customer/terms-conditions';
      final isPrivacyRoute =
          state.matchedLocation == '/customer/privacy-policy';

      // Allow access to Terms and Privacy without authentication
      if (isTermsRoute || isPrivacyRoute) {
        return null;
      }

      // Check if auth state is still loading
      if (!authStateAsync.hasValue) {
        return isSplashRoute ? null : '/splash';
      }

      final authState = authStateAsync.value!;

      // Pattern matching with sealed class
      return switch (authState) {
        AuthStateInitial() => isSplashRoute ? null : '/splash',
        AuthStateLoading() => isSplashRoute ? null : '/splash',
        AuthStateUnauthenticated() => isLoginRoute ? null : '/login',
        AuthStateUnverified() => isVerifyRoute ? null : '/verify-email',
        AuthStateAuthenticated(:final role) => () {
            // If on login/verify/splash, redirect to main app
            if (isLoginRoute || isVerifyRoute || isSplashRoute) {
              // Redirect based on role
              if (role?.toLowerCase() == 'admin') {
                return '/admin/pos';
              } else {
                return '/customer/menu';
              }
            }

            // Already on correct route, don't redirect
            return null;
          }(),
        AuthStateError() => isLoginRoute ? null : '/login',
      };
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),

      // Customer Routes
      GoRoute(
        path: '/customer/menu',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: '/customer/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/customer/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/customer/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/customer/orders/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/customer/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/customer/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/customer/terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/customer/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/pos',
        builder: (context, state) => const PosScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrdersScreen(),
            routes: [
              GoRoute(
                path: ':orderId',
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return OrderDetailScreen(orderId: orderId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: 'waste-logs',
                builder: (context, state) => const WasteLogsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'addons',
            builder: (context, state) => const AddOnManagementScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.coffee,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Coffee House POS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
