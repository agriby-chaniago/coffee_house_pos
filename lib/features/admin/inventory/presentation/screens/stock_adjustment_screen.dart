import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/auth/presentation/providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/stock_adjustment_provider.dart';

class StockAdjustmentScreen extends ConsumerStatefulWidget {
  final Product? product;

  const StockAdjustmentScreen({super.key, this.product});

  @override
  ConsumerState<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends ConsumerState<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  String _adjustmentType = 'restock';
  String? _wasteReason;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.product;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(inventoryProductsProvider);
    final adjustmentState = ref.watch(stockAdjustmentProvider);
    final authState = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
      ),
      body: productsAsync.when(
        data: (products) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product selector
                  DropdownButtonFormField<Product>(
                    initialValue: _selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Select product'),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(
                          '${product.name} (${product.currentStock.toStringAsFixed(1)} ${product.stockUnit})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProduct = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a product';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Adjustment type
                  Text(
                    'Adjustment Type',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'restock',
                        label: Text('Restock'),
                        icon: Icon(Icons.add_box),
                      ),
                      ButtonSegment(
                        value: 'waste',
                        label: Text('Waste'),
                        icon: Icon(Icons.delete_outline),
                      ),
                      ButtonSegment(
                        value: 'adjustment',
                        label: Text('Manual'),
                        icon: Icon(Icons.edit),
                      ),
                    ],
                    selected: {_adjustmentType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _adjustmentType = newSelection.first;
                        _wasteReason = null;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Current stock info card
                  if (_selectedProduct != null)
                    Card(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Stock',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedProduct!.currentStock.toStringAsFixed(1)} ${_selectedProduct!.stockUnit}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_selectedProduct != null) const SizedBox(height: 24),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: _adjustmentType == 'adjustment'
                          ? 'New Stock Amount'
                          : 'Amount',
                      suffixText: _selectedProduct?.stockUnit ?? '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Waste reason (only for waste type)
                  if (_adjustmentType == 'waste') ...[
                    DropdownButtonFormField<String>(
                      initialValue: _wasteReason,
                      decoration: InputDecoration(
                        labelText: 'Waste Reason',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: const Text('Select reason'),
                      items: WasteReason.values.map((reason) {
                        return DropdownMenuItem(
                          value: reason.name,
                          child: Text(reason.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _wasteReason = value;
                        });
                      },
                      validator: (value) {
                        if (_adjustmentType == 'waste' && value == null) {
                          return 'Please select waste reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add additional notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: adjustmentState.isLoading
                          ? null
                          : () => _submitAdjustment(authState),
                      icon: adjustmentState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        adjustmentState.isLoading
                            ? 'Processing...'
                            : 'Submit Adjustment',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading products: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitAdjustment(AuthState? authState) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) return;

    String userId = 'unknown';
    String userName = 'Unknown User';

    if (authState is AuthStateAuthenticated) {
      userId = authState.user.$id;
      userName = authState.user.name;
    }

    final amount = double.parse(_amountController.text);

    final success = await ref
        .read(stockAdjustmentProvider.notifier)
        .adjustStock(
          product: _selectedProduct!,
          adjustmentType: _adjustmentType,
          amount: amount,
          reason: _wasteReason,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          performedBy: userId,
          performedByName: userName,
        );

    if (!mounted) return;

    if (success) {
      ref.invalidate(inventoryProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock adjusted successfully: ${_selectedProduct!.name}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(stockAdjustmentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
