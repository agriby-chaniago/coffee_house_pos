import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/addon_model.dart';
import '../providers/edit_addon_provider.dart';
import '../providers/addons_provider.dart';

class EditAddOnScreen extends ConsumerStatefulWidget {
  final AddOn addon;

  const EditAddOnScreen({super.key, required this.addon});

  @override
  ConsumerState<EditAddOnScreen> createState() => _EditAddOnScreenState();
}

class _EditAddOnScreenState extends ConsumerState<EditAddOnScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _sortOrderController;

  late String _selectedCategory;
  late bool _isDefault;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addon.name);
    _priceController = TextEditingController(
      text: widget.addon.additionalPrice.toStringAsFixed(0),
    );
    _sortOrderController = TextEditingController(
      text: widget.addon.sortOrder.toString(),
    );
    _selectedCategory = widget.addon.category;
    _isDefault = widget.addon.isDefault;
    _isActive = widget.addon.isActive;
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
    final theme = Theme.of(context);
    final state = ref.watch(editAddOnProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Add-on'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
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
              value: _selectedCategory,
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
              label: const Text('Update Add-on'),
              onPressed: state.isLoading ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(editAddOnProvider.notifier).updateAddOn(
          addOnId: widget.addon.id!,
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
          content: Text('"${_nameController.text}" updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(editAddOnProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Add-on'),
        content: Text(
          'Are you sure you want to delete "${widget.addon.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(editAddOnProvider.notifier).deleteAddOn(
            addOnId: widget.addon.id!,
          );

      if (mounted) {
        if (success) {
          ref.invalidate(addonsProvider);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${widget.addon.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final error = ref.read(editAddOnProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error ?? "Unknown error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
