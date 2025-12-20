import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 400.ms,
                ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 400.ms,
                ),
            const SizedBox(height: 32),

            // Action Button
            if (actionLabel != null && onAction != null)
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
          ],
        ),
      ),
    );
  }
}

// Specific Empty States
class EmptyCartState extends StatelessWidget {
  final VoidCallback onBrowseMenu;

  const EmptyCartState({
    super.key,
    required this.onBrowseMenu,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Cart is Empty',
      message: 'Add some delicious items to your cart to get started!',
      actionLabel: 'Browse Menu',
      onAction: onBrowseMenu,
      iconColor: const Color(0xFFDF8E1D), // Peach
    );
  }
}

class EmptyOrdersState extends StatelessWidget {
  final VoidCallback onOrderNow;

  const EmptyOrdersState({
    super.key,
    required this.onOrderNow,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Orders Yet',
      message: 'Start your coffee journey by placing your first order!',
      actionLabel: 'Order Now',
      onAction: onOrderNow,
      iconColor: const Color(0xFFCBA6F7), // Mauve
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: searchQuery.isEmpty
          ? 'Try searching for your favorite coffee or snack'
          : 'No items match "$searchQuery".\nTry a different search term.',
      iconColor: const Color(0xFF94E2D5), // Teal
    );
  }
}

class EmptyFilteredOrdersState extends StatelessWidget {
  final String filterStatus;

  const EmptyFilteredOrdersState({
    super.key,
    required this.filterStatus,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.filter_list_off,
      title: 'No $filterStatus Orders',
      message: 'You don\'t have any orders with "$filterStatus" status.',
      iconColor: Colors.grey,
    );
  }
}
