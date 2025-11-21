import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_variant_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/addon_model.dart';
import 'package:coffee_house_pos/features/customer/cart/data/models/selected_addon_model.dart';
import '../providers/cart_provider.dart';

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
}

class AddToCartDialog extends ConsumerStatefulWidget {
  final Product product;
  final List<AddOn> availableAddons;

  const AddToCartDialog({
    super.key,
    required this.product,
    required this.availableAddons,
  });

  @override
  ConsumerState<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends ConsumerState<AddToCartDialog> {
  late ProductVariant _selectedVariant;
  final Set<String> _selectedAddonIds = {};
  int _quantity = 1;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.variants.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _itemPrice {
    final variantPrice = _selectedVariant.price;
    final addonsPrice = widget.availableAddons
        .where((addon) => _selectedAddonIds.contains(addon.id))
        .fold<double>(0, (sum, addon) => sum + addon.additionalPrice);
    return variantPrice + addonsPrice;
  }

  double get _totalPrice => _itemPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.product.description,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Variant selection
                    Text(
                      'Select Size',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: widget.product.variants.map((variant) {
                        final isSelected =
                            _selectedVariant.size == variant.size;
                        return ChoiceChip(
                          label: Text(
                              '${variant.size} - ${formatCurrency(variant.price)}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVariant = variant;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Addons selection
                    if (widget.availableAddons.isNotEmpty) ...[
                      Text(
                        'Add-ons (Optional)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.availableAddons.map((addon) {
                        final isSelected = _selectedAddonIds.contains(addon.id);
                        return CheckboxListTile(
                          title: Text(addon.name),
                          subtitle:
                              Text('+${formatCurrency(addon.additionalPrice)}'),
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedAddonIds.add(addon.id!);
                              } else {
                                _selectedAddonIds.remove(addon.id);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // Quantity selector
                    Text(
                      'Quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: _quantity > 1
                              ? () {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notes
                    Text(
                      'Special Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Less sugar, Extra ice...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        formatCurrency(_totalPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final selectedAddons = widget.availableAddons
                            .where(
                                (addon) => _selectedAddonIds.contains(addon.id))
                            .map((addon) => SelectedAddOn(
                                  addOnId: addon.id!,
                                  name: addon.name,
                                  additionalPrice: addon.additionalPrice,
                                  category: addon.category,
                                ))
                            .toList();

                        final cartItem = CartItem(
                          productId: widget.product.id ?? '',
                          productName: widget.product.name,
                          variantName: _selectedVariant.size,
                          variantPrice: _selectedVariant.price,
                          addons: selectedAddons,
                          quantity: _quantity,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        );

                        ref.read(cartProvider.notifier).addItem(cartItem);

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${widget.product.name} added to cart'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
