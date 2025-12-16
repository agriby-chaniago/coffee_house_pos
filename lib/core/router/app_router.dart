import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/customer/menu/presentation/screens/menu_screen.dart';
import '../../features/customer/cart/presentation/screens/cart_screen.dart';
import '../../features/customer/orders/presentation/screens/order_history_screen.dart';
import '../../features/customer/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/profile/presentation/screens/profile_screen.dart';
import '../../features/admin/pos/presentation/screens/pos_screen.dart';
import '../../features/admin/inventory/presentation/screens/inventory_screen.dart';
import '../../features/admin/inventory/presentation/screens/waste_logs_screen.dart';
import '../../features/admin/reports/presentation/screens/reports_screen.dart';
import '../../features/admin/settings/presentation/screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isVerifyRoute = state.matchedLocation == '/verify-email';
      final isSplashRoute = state.matchedLocation == '/splash';

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

      // Admin Routes
      GoRoute(
        path: '/admin/pos',
        builder: (context, state) => const PosScreen(),
        routes: [
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
