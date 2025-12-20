import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import 'package:go_router/go_router.dart';
import '../providers/menu_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_modal.dart';
import 'package:shimmer/shimmer.dart';
import 'package:coffee_house_pos/features/customer/shared/widgets/customer_bottom_nav.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../admin/settings/presentation/providers/settings_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuAsync = ref.watch(filteredMenuProvider);
    final selectedCategory = ref.watch(menuCategoryProvider);
    final storeInfo = ref.watch(storeInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          storeInfo.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final unreadCount = ref.watch(unreadNotificationsCountProvider);
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF38BA8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => context.push('/customer/notifications'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_rounded),
            onPressed: () => context.push('/customer/cart'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(menuProvider);
        },
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(theme),

            // Category Tabs
            _buildCategoryTabs(theme, selectedCategory),

            // Product Grid
            Expanded(
              child: menuAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return _buildEmptyState(theme);
                  }
                  return _buildProductGrid(products);
                },
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => _buildErrorState(theme, error),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Cari kopi, makanan, dessert...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _searchController.clear();
                    });
                    ref.read(menuSearchProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {});
          ref.read(menuSearchProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme, String selectedCategory) {
    final categories = [
      'All',
      'Favorite',
      'Coffee',
      'Non-Coffee',
      'Food',
      'Dessert'
    ];

    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          final categoryColor = category == 'All'
              ? theme.colorScheme.primary
              : getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedScale(
              scale: isSelected ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  ref.read(menuCategoryProvider.notifier).state = category;
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: categoryColor.withOpacity(0.15),
                checkmarkColor: categoryColor,
                elevation: isSelected ? 2 : 0,
                shadowColor: categoryColor.withOpacity(0.3),
                labelStyle: TextStyle(
                  color:
                      isSelected ? categoryColor : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: BorderSide(
                  color: isSelected
                      ? categoryColor
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: ProductCard(
            product: product,
            onTap: () async {
              final result = await showProductDetailModal(context, product);
              if (result != null && result['success'] == true && mounted) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${result['productName']} ditambahkan ke keranjang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: result['categoryColor'] as Color?,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Lihat',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        context.push('/customer/cart');
                      },
                    ),
                  ),
                );
                // Force dismiss after 5 seconds
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                });
              }
            },
            onQuickAdd: () async {
              // Open modal instead of quick add
              final result = await showProductDetailModal(context, product);
              if (result != null && result['success'] == true && mounted) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${result['productName']} ditambahkan ke keranjang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: result['categoryColor'] as Color?,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Lihat',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        context.push('/customer/cart');
                      },
                    ),
                  ),
                );
                // Force dismiss after 5 seconds
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                });
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceContainerHighest,
          highlightColor: theme.colorScheme.surface,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 14,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada produk ditemukan',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Coba sesuaikan pencarian atau filter Anda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _searchController.clear();
                  });
                  ref.read(menuSearchProvider.notifier).state = '';
                  ref.read(menuCategoryProvider.notifier).state = 'All';
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Filter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(menuProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
