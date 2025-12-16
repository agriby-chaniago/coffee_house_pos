import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/addon_model.dart';
import '../providers/addons_provider.dart';
import '../providers/edit_addon_provider.dart';
import 'add_addon_screen.dart';
import 'edit_addon_screen.dart';

class AddOnManagementScreen extends ConsumerStatefulWidget {
  const AddOnManagementScreen({super.key});

  @override
  ConsumerState<AddOnManagementScreen> createState() =>
      _AddOnManagementScreenState();
}

class _AddOnManagementScreenState extends ConsumerState<AddOnManagementScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addonsAsync = ref.watch(addonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add-ons Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Add New Add-on',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddAddOnScreen(),
                ),
              );
              ref.invalidate(addonsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == 'All',
                    onSelected: (_) =>
                        setState(() => _selectedCategory = 'All'),
                  ),
                  ...AddOnCategory.all.map((category) {
                    return FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Add-ons list
          Expanded(
            child: addonsAsync.when(
              data: (addons) {
                final filtered = _selectedCategory == 'All'
                    ? addons
                    : addons
                        .where((a) => a.category == _selectedCategory)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No add-ons found',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: theme.colorScheme.outline),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Your First Add-on'),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddOnScreen(),
                              ),
                            );
                            ref.invalidate(addonsProvider);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(addonsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final addon = filtered[index];
                      return _AddOnCard(
                        addon: addon,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAddOnScreen(addon: addon),
                            ),
                          );
                          ref.invalidate(addonsProvider);
                        },
                        onDelete: () => _confirmDelete(addon),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(addonsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(AddOn addon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Add-on'),
        content: Text(
          'Are you sure you want to delete "${addon.name}"?\n\n'
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
            addOnId: addon.id!,
          );

      if (mounted) {
        if (success) {
          ref.invalidate(addonsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${addon.name}" deleted successfully'),
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

class _AddOnCard extends StatelessWidget {
  final AddOn addon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AddOnCard({
    required this.addon,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: addon.isActive
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _getCategoryIcon(addon.category),
            color: addon.isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.outline,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                addon.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: addon.isActive ? null : theme.colorScheme.outline,
                ),
              ),
            ),
            if (addon.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(addon.category),
            Text(
              '+Rp ${addon.additionalPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#${addon.sortOrder}',
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case AddOnCategory.topping:
        return Icons.icecream;
      case AddOnCategory.sweetener:
        return Icons.water_drop;
      case AddOnCategory.milk:
        return Icons.water;
      case AddOnCategory.syrup:
        return Icons.local_drink;
      case AddOnCategory.coffee:
        return Icons.coffee;
      default:
        return Icons.add_circle;
    }
  }
}
