import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/order_history_provider.dart';
import '../providers/order_realtime_provider.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import 'package:coffee_house_pos/features/customer/shared/widgets/customer_bottom_nav.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(filteredOrderHistoryProvider);
    final currentFilter = ref.watch(orderHistoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(orderHistoryProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(theme, 'all', 'All', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'pending', 'Pending', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(
                    theme, 'preparing', 'Preparing', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'ready', 'Ready', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(
                    theme, 'completed', 'Completed', currentFilter),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by order number...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(orderHistorySearchProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(orderHistorySearchProvider.notifier).state = value;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(orderHistoryProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, theme, order);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    const Text('Failed to load orders'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => ref.invalidate(orderHistoryProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterChip(
      ThemeData theme, String value, String label, String currentFilter) {
    final isSelected = value == currentFilter;
    final statusColor = value != 'all'
        ? Color(orderStatusColors[value] ?? 0xFF9399B2)
        : theme.colorScheme.primary;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        ref.read(orderHistoryFilterProvider.notifier).state = value;
      },
      selectedColor: statusColor.withOpacity(0.3),
      checkmarkColor: statusColor,
      side: BorderSide(
        color: isSelected ? statusColor : theme.colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, ThemeData theme, Map<String, dynamic> order) {
    final orderId = order['\$id'] as String? ?? '';
    final orderNumber = order['orderNumber'] as String? ?? 'N/A';
    final status = order['status'] as String? ?? 'pending';
    final createdAt = order['createdAt'] as String?;
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;

    // Parse items from JSON string
    List items = [];
    try {
      if (order['items'] is String) {
        items = jsonDecode(order['items']) as List;
      } else if (order['items'] is List) {
        items = order['items'] as List;
      }
    } catch (e) {
      print('Error parsing items: $e');
    }

    final statusColor = Color(orderStatusColors[status] ?? 0xFF9399B2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/customer/orders/$orderId');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(
                      _getStatusIcon(status),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#$orderNumber',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm')
                                .format(DateTime.parse(createdAt)),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusTitle(status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Items Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${items.length} item${items.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/customer/menu'),
            icon: const Icon(Icons.store),
            label: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildBottomNav() {
    return const CustomerBottomNav(currentIndex: 1);
  }
}
