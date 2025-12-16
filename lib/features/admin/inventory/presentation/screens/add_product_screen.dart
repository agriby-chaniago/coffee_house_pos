import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import '../providers/product_form_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/addons_provider.dart';
import '../../../pos/presentation/providers/products_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceMController = TextEditingController();
  final _stockUsageMController = TextEditingController();
  final _priceLController = TextEditingController();
  final _stockUsageLController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _minStockController = TextEditingController();

  String _selectedCategory = AppConstants.productCategories.first;
  String _selectedStockUnit = AppConstants.stockUnits.first;
  File? _selectedImage;
  final Set<String> _selectedAddOnIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceMController.dispose();
    _stockUsageMController.dispose();
    _priceLController.dispose();
    _stockUsageLController.dispose();
    _initialStockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(productFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker - simple
              Center(
                child: GestureDetector(
                  onTap: formState.isLoading ? null : _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: theme.colorScheme.error,
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Caffe Latte',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Product description...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.productCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Variants section
              Text(
                'Product Variants',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Size M
              _buildVariantCard(
                theme: theme,
                size: 'M',
                priceController: _priceMController,
                stockUsageController: _stockUsageMController,
                stockUnit: _selectedStockUnit,
              ),

              const SizedBox(height: 12),

              // Size L
              _buildVariantCard(
                theme: theme,
                size: 'L',
                priceController: _priceLController,
                stockUsageController: _stockUsageLController,
                stockUnit: _selectedStockUnit,
              ),

              const SizedBox(height: 24),

              // Stock Management
              Text(
                'Stock Management',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Stock unit
              DropdownButtonFormField<String>(
                initialValue: _selectedStockUnit,
                decoration: InputDecoration(
                  labelText: 'Stock Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.stockUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStockUnit = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Initial stock & Min stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _initialStockController,
                      decoration: InputDecoration(
                        labelText: 'Initial Stock',
                        suffixText: _selectedStockUnit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Initial stock is required';
                        }
                        final num = double.tryParse(value);
                        if (num == null) {
                          return 'Invalid number';
                        }
                        if (num < 0) {
                          return 'Cannot be negative';
                        }
                        if (num > 1000000) {
                          return 'Value too large';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: InputDecoration(
                        labelText: 'Min Stock',
                        suffixText: _selectedStockUnit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Min stock is required';
                        }
                        final num = double.tryParse(value);
                        if (num == null) {
                          return 'Invalid number';
                        }
                        if (num < 0) {
                          return 'Cannot be negative';
                        }
                        if (num > 1000000) {
                          return 'Value too large';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // Available Add-ons
              Text(
                'Available Add-ons',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select which add-ons/toppings are available for this product',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildAddOnsSection(theme),

              const SizedBox(height: 32),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: formState.isLoading ? null : _submitForm,
                  icon: formState.isLoading
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
                    formState.isLoading ? 'Creating...' : 'Create Product',
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantCard({
    required ThemeData theme,
    required String size,
    required TextEditingController priceController,
    required TextEditingController stockUsageController,
    required String stockUnit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Size $size',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      final num = double.tryParse(value);
                      if (num == null) {
                        return 'Invalid number';
                      }
                      if (num <= 0) {
                        return 'Must be greater than 0';
                      }
                      if (num > 10000000) {
                        return 'Price too large';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: stockUsageController,
                    decoration: InputDecoration(
                      labelText: 'Stock Usage',
                      suffixText: stockUnit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stock usage is required';
                      }
                      final num = double.tryParse(value);
                      if (num == null) {
                        return 'Invalid number';
                      }
                      if (num <= 0) {
                        return 'Must be greater than 0';
                      }
                      if (num > 100000) {
                        return 'Value too large';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsSection(ThemeData theme) {
    final addOnsAsync = ref.watch(addonsProvider);

    return addOnsAsync.when(
      data: (addOns) {
        if (addOns.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No add-ons available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create add-ons in Toppings Management first',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Counter and limit info
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: _selectedAddOnIds.length >= 5
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected: ${_selectedAddOnIds.length}/5',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _selectedAddOnIds.length >= 5
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedAddOnIds.length >= 5) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(Maximum reached)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...addOns.map((addOn) {
                  final isSelected = _selectedAddOnIds.contains(addOn.id);
                  final canSelect = isSelected || _selectedAddOnIds.length < 5;

                  return CheckboxListTile(
                    title: Text(
                      addOn.name,
                      style: TextStyle(
                        color: canSelect
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    subtitle: Text(
                      '${addOn.category} • +Rp ${addOn.additionalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: canSelect
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4),
                      ),
                    ),
                    value: isSelected,
                    onChanged: canSelect
                        ? (bool? value) {
                            setState(() {
                              if (value == true) {
                                if (_selectedAddOnIds.length < 5) {
                                  _selectedAddOnIds.add(addOn.id!);
                                }
                              } else {
                                _selectedAddOnIds.remove(addOn.id);
                              }
                            });
                          }
                        : null,
                    dense: true,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading add-ons: $error',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await ref.read(productFormProvider.notifier).pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(productFormProvider.notifier).createProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          imageFile: _selectedImage,
          priceM: double.parse(_priceMController.text),
          stockUsageM: double.parse(_stockUsageMController.text),
          priceL: double.parse(_priceLController.text),
          stockUsageL: double.parse(_stockUsageLController.text),
          stockUnit: _selectedStockUnit,
          initialStock: double.parse(_initialStockController.text),
          minStock: double.parse(_minStockController.text),
          availableAddOnIds: _selectedAddOnIds.toList(),
        );

    if (!mounted) return;

    if (success) {
      // Invalidate both inventory and POS products
      ref.invalidate(inventoryProductsProvider);
      ref.invalidate(productsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Product "${_nameController.text}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(productFormProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
