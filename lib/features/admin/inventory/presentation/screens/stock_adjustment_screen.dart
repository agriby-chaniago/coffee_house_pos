import 'package:flutter/material.dart';
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
                  Text(
                    'Product',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Product>(
                    initialValue: _selectedProduct,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.inventory_2),
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
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
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

                  // Amount
                  Text(
                    _adjustmentType == 'adjustment'
                        ? 'New Stock Amount'
                        : 'Amount',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.numbers),
                      suffixText: _selectedProduct?.stockUnit ?? '',
                      helperText: _selectedProduct != null
                          ? 'Current: ${_selectedProduct!.currentStock.toStringAsFixed(1)} ${_selectedProduct!.stockUnit}'
                          : null,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                    Text(
                      'Waste Reason',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _wasteReason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.error_outline),
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
                  Text(
                    'Notes (Optional)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note),
                      hintText: 'Add additional notes...',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
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
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading products: $error'),
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
      // Refresh inventory
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
