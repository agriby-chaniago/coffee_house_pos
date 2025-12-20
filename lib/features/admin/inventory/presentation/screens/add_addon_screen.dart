import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/addon_model.dart';
import '../providers/addon_form_provider.dart';
import '../providers/addons_provider.dart';

class AddAddOnScreen extends ConsumerStatefulWidget {
  const AddAddOnScreen({super.key});

  @override
  ConsumerState<AddAddOnScreen> createState() => _AddAddOnScreenState();
}

class _AddAddOnScreenState extends ConsumerState<AddAddOnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String _selectedCategory = AddOnCategory.topping;
  bool _isDefault = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    // Auto-calculate sortOrder after frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateNextSortOrder();
    });
  }

  void _calculateNextSortOrder() {
    final addonsAsync = ref.read(addonsProvider);
    addonsAsync.whenData((addons) {
      final maxSortOrder = addons.isEmpty
          ? 0
          : addons.map((a) => a.sortOrder).reduce((a, b) => a > b ? a : b);
      setState(() {
        _sortOrderController.text = (maxSortOrder + 1).toString();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addOnFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Add-on'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g., Pearl, Extra Shot, Oat Milk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: AddOnCategory.all.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Additional Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Additional Price (Rp) *',
                hintText: '0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Invalid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sort Order
            TextFormField(
              controller: _sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Sort Order',
                hintText: '0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sort),
                helperText: 'Lower numbers appear first',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sort order is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Is Default
            SwitchListTile(
              title: const Text('Set as Default'),
              subtitle: const Text('Pre-selected for this category'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),

            // Is Active
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Show in POS'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 24),

            // Submit Button
            FilledButton.icon(
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Add-on'),
              onPressed: state.isLoading ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(addOnFormProvider.notifier).createAddOn(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          additionalPrice: double.parse(_priceController.text),
          isDefault: _isDefault,
          sortOrder: int.parse(_sortOrderController.text),
          isActive: _isActive,
        );

    if (!mounted) return;

    if (success) {
      ref.invalidate(addonsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_nameController.text}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(addOnFormProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
