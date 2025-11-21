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

    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);

    // Safely get variants with fallback values
    final variantM = widget.product.variants.firstWhere(
      (v) => v.size == 'M',
      orElse: () => const ProductVariant(size: 'M', price: 0, stockUsagePerUnit: 1),
    );
    final variantL = widget.product.variants.firstWhere(
      (v) => v.size == 'L',
      orElse: () => const ProductVariant(size: 'L', price: 0, stockUsagePerUnit: 1.5),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: editState.isLoading ? null : _pickImage,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: _newImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _newImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.product.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 48,
                                        color: theme.colorScheme.outline,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to change',
                                        style: TextStyle(
                                          color: theme.colorScheme.outline,
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
                                    size: 48,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add photo',
                                    style: TextStyle(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product name
              Text('Product Name', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
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
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
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
              Text('Category', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
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
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildVariantSection(
                theme: theme,
                size: 'M',
                priceController: _priceMController,
                stockUsageController: _stockUsageMController,
              ),

              const SizedBox(height: 16),

              _buildVariantSection(
                theme: theme,
                size: 'L',
                priceController: _priceLController,
                stockUsageController: _stockUsageLController,
              ),

              const SizedBox(height: 24),

              // Stock section
              Text(
                'Stock Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Stock unit
              Text('Stock Unit', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedStockUnit,
                decoration: InputDecoration(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Stock',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue:
                              widget.product.currentStock.toStringAsFixed(1),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixText: _selectedStockUnit,
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceContainerHighest,
                          ),
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Min Stock', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _minStockController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixText: _selectedStockUnit,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num < 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
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
              ),

              const SizedBox(height: 32),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 56,
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariantSection({
    required ThemeData theme,
    required String size,
    required TextEditingController priceController,
    required TextEditingController stockUsageController,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Size $size',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price (IDR)', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stock Usage', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: stockUsageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixText: _selectedStockUnit,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final num = double.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ],
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
      ref.invalidate(inventoryProductsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated: ${_nameController.text}'),
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
}
