import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_house_pos/core/theme/app_theme.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/customer/menu');
            break;
          case 1:
            context.go('/customer/orders');
            break;
          case 2:
            context.go('/customer/profile');
            break;
        }
      },
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: AppTheme.peach.withOpacity(0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: AppTheme.peach,
          ),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(
            Icons.receipt_long,
            color: AppTheme.peach,
          ),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(
            Icons.person,
            color: AppTheme.peach,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
