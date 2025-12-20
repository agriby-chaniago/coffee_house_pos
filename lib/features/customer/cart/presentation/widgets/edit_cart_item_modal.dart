import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_house_pos/features/customer/cart/data/models/cart_item_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import '../../../menu/presentation/providers/addons_provider.dart';
import '../providers/customer_cart_provider.dart';
import '../../../../admin/inventory/data/models/addon_model.dart';

class EditCartItemModal extends ConsumerStatefulWidget {
  final CartItem cartItem;
  final Product product;

  const EditCartItemModal({
    super.key,
    required this.cartItem,
    required this.product,
  });

  @override
  ConsumerState<EditCartItemModal> createState() => _EditCartItemModalState();
}

class _EditCartItemModalState extends ConsumerState<EditCartItemModal> {
  late int _selectedVariantIndex;
  late int _quantity;
  late Set<String> _selectedAddonIds;

  @override
  void initState() {
    super.initState();
    // Initialize with current cart item values
    _selectedVariantIndex = widget.product.variants
        .indexWhere((v) => v.size == widget.cartItem.size);
    if (_selectedVariantIndex == -1) _selectedVariantIndex = 0;

    _quantity = widget.cartItem.quantity;
    _selectedAddonIds =
        widget.cartItem.addons.map((a) => a.id).whereType<String>().toSet();
  }

  double get _calculatedPrice {
    double basePrice = widget.product.variants.isNotEmpty
        ? widget.product.variants[_selectedVariantIndex].price
        : 0.0;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Item',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: widget.product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.product.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.coffee, size: 80),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Size Selector
                  if (widget.product.variants.length > 1) ...[
                    Text(
                      'Size',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: List.generate(
                        widget.product.variants.length,
                        (index) {
                          final variant = widget.product.variants[index];
                          final isSelected = _selectedVariantIndex == index;
                          return ChoiceChip(
                            selected: isSelected,
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(variant.size),
                                Text(
                                  CurrencyFormatter.format(variant.price),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedVariantIndex = index);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Add-ons Section
                  _buildAddonsSection(theme),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        iconSize: 32,
                        onPressed: _quantity > 1
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() => _quantity--);
                              }
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_quantity',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        iconSize: 32,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
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
                        Text(
                          CurrencyFormatter.format(_calculatedPrice),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _updateCart(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Update Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsSection(ThemeData theme) {
    if (widget.product.availableAddOnIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final addonsAsync = ref.watch(addonsProvider);

    return addonsAsync.when(
      data: (allAddons) {
        final availableAddons = allAddons
            .where(
                (addon) => widget.product.availableAddOnIds.contains(addon.id))
            .toList();

        if (availableAddons.isEmpty) {
          return const SizedBox.shrink();
        }

        final grouped = <String, List<AddOn>>{};
        for (final addon in availableAddons) {
          grouped.putIfAbsent(addon.category, () => []).add(addon);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize Your Order',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  void _updateCart(BuildContext context) {
    final selectedVariant = widget.product.variants[_selectedVariantIndex];

    final updatedItem = CartItem(
      id: widget.cartItem.id, // Keep same ID
      productId: widget.product.id!,
      productName: widget.product.name,
      productImage: widget.product.imageUrl,
      size: selectedVariant.size,
      price: selectedVariant.price,
      quantity: _quantity,
      addons: _getSelectedAddons,
      notes: widget.cartItem.notes,
    );

    ref.read(customerCartProvider.notifier).updateItem(updatedItem);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} updated in cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }
}
