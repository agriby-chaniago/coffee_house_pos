import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import 'package:coffee_house_pos/features/admin/pos/presentation/providers/cart_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(filteredOrdersProvider);
    final filter = ref.watch(ordersFilterProvider);
    final stats = ref.watch(ordersStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allOrdersProvider);
        },
        child: Column(
          children: [
            // Stats cards
            _buildStatsCards(theme, stats),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by order number or customer...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                            ref
                                .read(ordersFilterProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  ref.read(ordersFilterProvider.notifier).setSearchQuery(value);
                },
              ),
            ),

            // Status filter chips
            _buildFilterChips(theme, filter),

            // Date range and reset filters
            _buildFilterActions(context, theme, filter),

            const Divider(height: 1),

            // Orders list
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          context.push('/admin/pos/orders/${order.id}');
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading orders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          ref.invalidate(allOrdersProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme, OrdersStats stats) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildStatCard(
            theme,
            'Total',
            stats.totalOrders.toString(),
            Icons.receipt_long,
            const Color(0xFF1E66F5), // blue
            const Color(0xFFDCE7F8),
          ),
          _buildStatCard(
            theme,
            'Pending',
            stats.pendingCount.toString(),
            Icons.schedule,
            const Color(0xFF7C7F93), // gray
            const Color(0xFFE3E4E8),
          ),
          _buildStatCard(
            theme,
            'Preparing',
            stats.preparingCount.toString(),
            Icons.restaurant,
            const Color(0xFF1E66F5), // blue
            const Color(0xFFDCE7F8),
          ),
          _buildStatCard(
            theme,
            'Ready',
            stats.readyCount.toString(),
            Icons.done,
            const Color(0xFFDF8E1D), // yellow
            const Color(0xFFFEF7E0),
          ),
          _buildStatCard(
            theme,
            'Completed',
            stats.completedCount.toString(),
            Icons.check_circle,
            const Color(0xFF40A02B), // green
            const Color(0xFFE6F4E1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, OrdersFilter filter) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.status == null,
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus(null);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pending'),
            selected: filter.status?.toLowerCase() == 'pending',
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus('pending');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Preparing'),
            selected: filter.status?.toLowerCase() == 'preparing',
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus('preparing');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Ready'),
            selected: filter.status?.toLowerCase() == 'ready',
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus('ready');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Completed'),
            selected: filter.status?.toLowerCase() == 'completed',
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus('completed');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Cancelled'),
            selected: filter.status?.toLowerCase() == 'cancelled',
            onSelected: (_) {
              ref.read(ordersFilterProvider.notifier).setStatus('cancelled');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterActions(
      BuildContext context, ThemeData theme, OrdersFilter filter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Date range button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDateRangePicker(context),
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                filter.startDate != null && filter.endDate != null
                    ? '${DateFormat('MMM dd').format(filter.startDate!)} - ${DateFormat('MMM dd').format(filter.endDate!)}'
                    : 'Date Range',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Reset filters button
          if (filter.status != null ||
              filter.startDate != null ||
              filter.searchQuery.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () {
                ref.read(ordersFilterProvider.notifier).reset();
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Reset', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final filter = ref.read(ordersFilterProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(
              start: filter.startDate!,
              end: filter.endDate!,
            )
          : null,
    );

    if (picked != null) {
      ref.read(ordersFilterProvider.notifier).setDateRange(
            picked.start,
            picked.end,
          );
    }
  }
}

// Add bottomNavigationBar to Scaffold - find and add after body
