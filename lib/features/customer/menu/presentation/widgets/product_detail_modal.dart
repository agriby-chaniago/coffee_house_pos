import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import '../providers/menu_provider.dart';
import '../providers/addons_provider.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/customer_cart_provider.dart';
import '../../../../admin/inventory/data/models/addon_model.dart';
import 'package:go_router/go_router.dart';

class ProductDetailModal extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailModal({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends ConsumerState<ProductDetailModal> {
  int _selectedVariantIndex = 0;
  int _quantity = 1;
  final Set<String> _selectedAddonIds = {};

  double get _calculatedPrice {
    double basePrice = widget.product.variants.isNotEmpty
        ? widget.product.variants[_selectedVariantIndex].price
        : 0.0;

    // Add addons price
    final addonsAsync = ref.read(addonsProvider);
    if (addonsAsync.hasValue) {
      final allAddons = addonsAsync.value ?? [];
      final selectedAddons =
          allAddons.where((a) => _selectedAddonIds.contains(a.id));
      double addonsTotal =
          selectedAddons.fold(0.0, (sum, addon) => sum + addon.additionalPrice);
      return (basePrice + addonsTotal) * _quantity;
    }

    return basePrice * _quantity;
  }

  List<AddOn> get _getSelectedAddons {
    final addonsAsync = ref.read(addonsProvider);
    if (!addonsAsync.hasValue) return [];

    final allAddons = addonsAsync.value ?? [];
    return allAddons.where((a) => _selectedAddonIds.contains(a.id)).toList();
  }

  void _incrementQuantity() {
    HapticFeedback.lightImpact();
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = getCategoryColor(widget.product.category);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Hero Image with Gradient
          _buildHeroImage(theme, categoryColor),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Category
                  _buildHeader(theme, categoryColor),
                  const SizedBox(height: 16),

                  // Description
                  _buildDescription(theme),
                  const SizedBox(height: 24),

                  // Size Selector
                  if (widget.product.variants.length > 1) ...[
                    _buildSizeSelector(theme, categoryColor),
                    const SizedBox(height: 24),
                  ],

                  // Add-ons Section
                  _buildAddonsSection(theme, categoryColor),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  _buildQuantitySelector(theme, categoryColor),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),

          // Bottom Bar (Price & Add to Cart)
          _buildBottomBar(theme, categoryColor),
        ],
      ),
    );
  }

  Widget _buildHeroImage(ThemeData theme, Color categoryColor) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Hero(
            tag: 'product-${widget.product.id}',
            child: widget.product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: categoryColor.withOpacity(0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: categoryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: categoryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.broken_image,
                        size: 80,
                        color: categoryColor.withOpacity(0.5),
                      ),
                    ),
                  )
                : Container(
                    color: categoryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.coffee,
                      size: 80,
                      color: categoryColor.withOpacity(0.5),
                    ),
                  ),
          ),

          // Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    categoryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: categoryColor.withOpacity(0.5)),
          ),
          child: Text(
            widget.product.category,
            style: TextStyle(
              color: categoryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Product Name
        Text(
          widget.product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.product.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }

  Widget _buildSizeSelector(ThemeData theme, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.product.variants.length, (index) {
          final variant = widget.product.variants[index];
          final isSelected = _selectedVariantIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedVariantIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? categoryColor.withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? categoryColor
                        : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Radio Icon
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? categoryColor
                              : theme.colorScheme.outline,
                          width: 2,
                        ),
                        color: isSelected ? categoryColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Size Name
                    Expanded(
                      child: Text(
                        variant.size,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? categoryColor
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Price
                    Text(
                      CurrencyFormatter.format(variant.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? categoryColor
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddonsSection(ThemeData theme, Color categoryColor) {
    // Debug logging
    print('🔍 Product: ${widget.product.name}');
    print('🔍 Available Add-on IDs: ${widget.product.availableAddOnIds}');

    // Check if product has any add-on IDs
    if (widget.product.availableAddOnIds.isEmpty) {
      print('ℹ️ Product has no add-on IDs configured');
      return const SizedBox.shrink();
    }

    // Watch the addons async state
    final addonsAsync = ref.watch(addonsProvider);

    return addonsAsync.when(
      data: (allAddons) {
        print('✅ All add-ons loaded: ${allAddons.length} total');
        print('🔍 Product expects IDs: ${widget.product.availableAddOnIds}');

        // Debug: Print all addon IDs
        print('📋 Available addon IDs in database:');
        for (final addon in allAddons) {
          print('   - ID: "${addon.id}" | Name: ${addon.name}');
        }

        // Filter addons for this product
        final availableAddons = allAddons
            .where(
                (addon) => widget.product.availableAddOnIds.contains(addon.id))
            .toList();

        print(
            '🔍 Filtered Add-ons for product: ${availableAddons.length} items');
        for (final addon in availableAddons) {
          print('   ✓ ${addon.name} (${addon.category}) [${addon.id}]');
        }

        if (availableAddons.isEmpty) {
          print('⚠️ No matching add-ons found for this product');
          return const SizedBox.shrink();
        }

        return _buildAddonsContent(theme, categoryColor, availableAddons);
      },
      loading: () {
        print('⏳ Loading add-ons...');
        return const SizedBox.shrink(); // or show shimmer
      },
      error: (err, stack) {
        print('❌ Error loading add-ons: $err');
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddonsContent(
      ThemeData theme, Color categoryColor, List<AddOn> availableAddons) {
    // Group addons by category
    final grouped = <String, List<AddOn>>{};
    for (final addon in availableAddons) {
      grouped.putIfAbsent(addon.category, () => []).add(addon);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: categoryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Customize Your Order',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  entry.key,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((addon) {
                  final isSelected = _selectedAddonIds.contains(addon.id);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(
                      '${addon.name} (+${CurrencyFormatter.format(addon.additionalPrice)})',
                    ),
                    onSelected: (selected) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (selected) {
                          _selectedAddonIds.add(addon.id!);
                        } else {
                          _selectedAddonIds.remove(addon.id);
                        }
                      });
                    },
                    selectedColor: categoryColor.withOpacity(0.3),
                    checkmarkColor: categoryColor,
                    side: BorderSide(
                      color: isSelected
                          ? categoryColor
                          : theme.colorScheme.outlineVariant,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildQuantitySelector(ThemeData theme, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement Button
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: _quantity > 1 ? _decrementQuantity : null,
                color: categoryColor,
              ),

              // Quantity Display
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  _quantity.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),

              // Increment Button
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: _incrementQuantity,
                color: categoryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Price',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(_calculatedPrice),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();

                  // Validate product ID
                  if (widget.product.id == null || widget.product.id!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Product ID tidak valid'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Create cart item
                  final variant =
                      widget.product.variants[_selectedVariantIndex];

                  // Get selected addons
                  final selectedAddons = _getSelectedAddons;

                  final cartItem = CartItem(
                    id: '${widget.product.id}_${variant.size}_${DateTime.now().millisecondsSinceEpoch}',
                    productId: widget.product.id!,
                    productName: widget.product.name,
                    productImage: widget.product.imageUrl,
                    size: variant.size,
                    price: variant.price,
                    quantity: _quantity,
                    addons: selectedAddons,
                    notes: '',
                  );

                  // Add to cart
                  ref.read(customerCartProvider.notifier).addItem(cartItem);

                  print(
                      '✅ Added to cart: ${cartItem.productName} (${cartItem.size}) x${cartItem.quantity}');
                  print(
                      '   Add-ons: ${selectedAddons.map((a) => a.name).join(", ")}');

                  // Close modal and return success with product data
                  Navigator.of(context).pop({
                    'success': true,
                    'productName': widget.product.name,
                    'categoryColor': categoryColor,
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Tambah ke Keranjang',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

// Helper function to show the modal
Future<Map<String, dynamic>?> showProductDetailModal(
    BuildContext context, Product product) async {
  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailModal(product: product),
  );
}
