import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_model.dart';
import 'package:coffee_house_pos/features/customer/menu/data/models/product_variant_model.dart';
import '../providers/edit_product_provider.dart';
import '../providers/inventory_provider.dart';
import '../../../pos/presentation/providers/products_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceMController;
  late TextEditingController _stockUsageMController;
  late TextEditingController _priceLController;
  late TextEditingController _stockUsageLController;
  late TextEditingController _minStockController;

  late String _selectedCategory;
  late String _selectedStockUnit;
  late bool _isActive;
  File? _newImage;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);

    final variantM = widget.product.variants.firstWhere(
      (v) => v.size == 'M',
      orElse: () =>
          const ProductVariant(size: 'M', price: 0, stockUsagePerUnit: 1),
    );
    final variantL = widget.product.variants.firstWhere(
      (v) => v.size == 'L',
      orElse: () =>
          const ProductVariant(size: 'L', price: 0, stockUsagePerUnit: 1.5),
    );

    _priceMController = TextEditingController(text: variantM.price.toString());
    _stockUsageMController =
        TextEditingController(text: variantM.stockUsagePerUnit.toString());
    _priceLController = TextEditingController(text: variantL.price.toString());
    _stockUsageLController =
        TextEditingController(text: variantL.stockUsagePerUnit.toString());
    _minStockController =
        TextEditingController(text: widget.product.minStock.toString());

    _selectedCategory = widget.product.category;
    _selectedStockUnit = widget.product.stockUnit;
    _isActive = widget.product.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceMController.dispose();
    _stockUsageMController.dispose();
    _priceLController.dispose();
    _stockUsageLController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editState = ref.watch(editProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Product',
            onPressed:
                editState.isLoading ? null : () => _showDeleteDialog(context),
          ),
        ],
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
                  onTap: editState.isLoading ? null : _pickImage,
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
                    child: _newImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  _newImage!,
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
                                      _newImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : widget.product.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 40,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to change',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

              _buildVariantCard(
                theme: theme,
                size: 'M',
                priceController: _priceMController,
                stockUsageController: _stockUsageMController,
                stockUnit: _selectedStockUnit,
              ),

              const SizedBox(height: 12),

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

              // Current stock (readonly) & Min stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          widget.product.currentStock.toStringAsFixed(1),
                      decoration: InputDecoration(
                        labelText: 'Current Stock',
                        suffixText: _selectedStockUnit,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      enabled: false,
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

              const SizedBox(height: 16),

              // Active status
              SwitchListTile(
                title: const Text('Product Active'),
                subtitle: Text(
                  _isActive ? 'Visible to customers' : 'Hidden from customers',
                ),
                value: _isActive,
                onChanged: editState.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: editState.isLoading ? null : _submitForm,
                  icon: editState.isLoading
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
                    editState.isLoading ? 'Updating...' : 'Update Product',
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

  Future<void> _pickImage() async {
    final image = await ref.read(editProductProvider.notifier).pickImage();
    if (image != null) {
      setState(() {
        _newImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(editProductProvider.notifier).updateProduct(
          productId: widget.product.id!,
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          existingImageUrl: widget.product.imageUrl,
          newImageFile: _newImage,
          priceM: double.parse(_priceMController.text),
          stockUsageM: double.parse(_stockUsageMController.text),
          priceL: double.parse(_priceLController.text),
          stockUsageL: double.parse(_stockUsageLController.text),
          stockUnit: _selectedStockUnit,
          minStock: double.parse(_minStockController.text),
          isActive: _isActive,
        );

    if (!mounted) return;

    if (success) {
      // Invalidate both inventory and POS products
      ref.invalidate(inventoryProductsProvider);
      ref.invalidate(productsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Product "${_nameController.text}" updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(editProductProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${widget.product.name}"?\n\n'
          'This action cannot be undone and will permanently remove:\n'
          '• Product information\n'
          '• Product image\n'
          '• All associated data',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteProduct();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    final success = await ref.read(editProductProvider.notifier).deleteProduct(
          productId: widget.product.id!,
          imageUrl: widget.product.imageUrl,
        );

    if (!mounted) return;

    if (success) {
      // Invalidate both inventory and POS products
      ref.invalidate(inventoryProductsProvider);
      ref.invalidate(productsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Product "${widget.product.name}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(editProductProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to delete product: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
