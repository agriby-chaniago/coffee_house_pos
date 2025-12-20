import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import '../providers/menu_provider.dart';
import '../providers/favorites_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor = getCategoryColor(product.category);

    // Get userId from auth state (StreamProvider returns AsyncValue)
    final authStateAsync = ref.watch(authStateProvider);
    final userId = authStateAsync.when(
      data: (authState) {
        if (authState is AuthStateAuthenticated) {
          return authState.user.$id;
        } else if (authState is AuthStateUnverified) {
          return authState.user.$id;
        }
        return null;
      },
      loading: () => null,
      error: (_, __) => null,
    );

    final isFavorite =
        ref.watch(favoritesProvider(userId)).contains(product.id);

    return Card(
      elevation: 2,
      shadowColor: categoryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        highlightColor: categoryColor.withOpacity(0.1),
        splashColor: categoryColor.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: categoryColor.withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.coffee,
                                    size: 48,
                                    color: categoryColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: categoryColor.withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: categoryColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: categoryColor.withOpacity(0.1),
                              child: Center(
                                child: Icon(
                                  Icons.coffee,
                                  size: 48,
                                  color: categoryColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(favoritesProvider(userId).notifier)
                              .toggleFavorite(product.id!);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Prices Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Prices
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.variants.length >= 2) ...[
                                // Show M price
                                Text(
                                  CurrencyFormatter.format(
                                      product.variants[0].price),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? categoryColor
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows:
                                        theme.brightness == Brightness.light
                                            ? [
                                                const Shadow(
                                                  color: Colors.white,
                                                  blurRadius: 3,
                                                ),
                                                const Shadow(
                                                  color: Colors.white,
                                                  blurRadius: 5,
                                                ),
                                              ]
                                            : null,
                                  ),
                                ),
                              ] else if (product.variants.isNotEmpty) ...[
                                Text(
                                  CurrencyFormatter.format(
                                      product.variants[0].price),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? categoryColor
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows:
                                        theme.brightness == Brightness.light
                                            ? [
                                                const Shadow(
                                                  color: Colors.white,
                                                  blurRadius: 3,
                                                ),
                                                const Shadow(
                                                  color: Colors.white,
                                                  blurRadius: 5,
                                                ),
                                              ]
                                            : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Quick Add Button
                        if (onQuickAdd != null)
                          Container(
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  onQuickAdd!();
                                },
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
