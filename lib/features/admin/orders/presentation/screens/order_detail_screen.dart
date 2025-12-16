import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';
import 'package:coffee_house_pos/features/admin/pos/presentation/services/receipt_service.dart';
import '../providers/orders_provider.dart';
import '../providers/order_actions_provider.dart';
import '../widgets/order_status_badge.dart';
import 'package:coffee_house_pos/features/admin/settings/presentation/providers/settings_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final actionState = ref.watch(orderActionsProvider);

    // Listen to action state changes
    ref.listen<OrderActionState>(orderActionsProvider, (previous, next) {
      next.maybeWhen(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: const Color(0xFF40A02B), // green
              duration: const Duration(seconds: 2),
            ),
          );
          // Refresh order
          ref.invalidate(orderByIdProvider(orderId));
          ref.invalidate(allOrdersProvider);
        },
        error: (message) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          orderAsync.when(
            data: (order) => IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'Print Receipt',
              onPressed: () {
                final storeInfo = ref.read(storeInfoProvider);
                ReceiptService.printReceipt(
                  order,
                  storeName: storeInfo.name,
                  storeAddress: storeInfo.address,
                  storePhone: storeInfo.phone,
                );
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              _buildOrderHeader(theme, order),
              const SizedBox(height: 24),

              // Items section
              _buildItemsSection(theme, order),
              const SizedBox(height: 24),

              // Payment summary
              _buildPaymentSummary(theme, order),
              const SizedBox(height: 24),

              // Completion/Cancellation info
              if (order.status.toLowerCase() == 'completed' ||
                  order.status.toLowerCase() == 'cancelled')
                _buildCompletionInfo(theme, order),

              // Action buttons (if not completed/cancelled)
              if (order.status.toLowerCase() != 'completed' &&
                  order.status.toLowerCase() != 'cancelled')
                _buildActionButtons(context, ref, order, actionState),
            ],
          ),
        ),
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
                'Error loading order',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(ThemeData theme, Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Number',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderNumber,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              Icons.access_time,
              'Date & Time',
              DateFormat('EEEE, MMM dd, yyyy · HH:mm').format(order.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.person_outline,
              'Cashier',
              order.cashierName,
            ),
            if (order.customerName != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                theme,
                Icons.person,
                'Customer',
                order.customerName!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(ThemeData theme, Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...order.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  _buildOrderItem(theme, item),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(ThemeData theme, dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.productName} (${item.selectedSize})',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} × ${CurrencyFormatter.format(item.basePrice)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(item.basePrice * item.quantity),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (item.addOns.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...item.addOns.map((addon) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '+ ${addon.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(addon.additionalPrice),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Item Total: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              CurrencyFormatter.format(item.itemTotal),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(ThemeData theme, Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              theme,
              'Subtotal',
              CurrencyFormatter.format(order.subtotal),
              false,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              theme,
              'PPN 11%',
              CurrencyFormatter.format(order.taxAmount),
              false,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildSummaryRow(
              theme,
              'TOTAL',
              CurrencyFormatter.format(order.total),
              true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    (order.paymentMethod ?? 'cash').toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value,
    bool isBold,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionInfo(ThemeData theme, Order order) {
    final isCompleted = order.status.toLowerCase() == 'completed';

    return Card(
      color: isCompleted
          ? const Color(0xFFE6F4E1) // green bg
          : const Color(0xFFFEE5EA), // red bg
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: isCompleted
                      ? const Color(0xFF40A02B)
                      : const Color(0xFFD20F39),
                ),
                const SizedBox(width: 8),
                Text(
                  isCompleted ? 'Order Completed' : 'Order Cancelled',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF40A02B)
                        : const Color(0xFFD20F39),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isCompleted && order.completedAt != null) ...[
              Text(
                'Completed at: ${DateFormat('MMM dd, yyyy · HH:mm').format(order.completedAt!)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (!isCompleted) ...[
              if (order.cancelledAt != null)
                Text(
                  'Cancelled at: ${DateFormat('MMM dd, yyyy · HH:mm').format(order.cancelledAt!)}',
                  style: theme.textTheme.bodyMedium,
                ),
              if (order.cancellationReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${order.cancellationReason}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Order order,
    OrderActionState actionState,
  ) {
    final isLoading = actionState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status transition button
        if (order.status.toLowerCase() == 'pending')
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => _updateStatus(ref, order.id!, 'preparing'),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.restaurant),
            label: const Text('Start Preparing'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1E66F5), // blue
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        if (order.status.toLowerCase() == 'preparing')
          FilledButton.icon(
            onPressed:
                isLoading ? null : () => _updateStatus(ref, order.id!, 'ready'),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: const Text('Mark as Ready'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDF8E1D), // yellow/orange
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        if (order.status.toLowerCase() == 'ready')
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => _updateStatus(ref, order.id!, 'completed'),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.done_all),
            label: const Text('Complete Order'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF40A02B), // green
              minimumSize: const Size.fromHeight(56),
            ),
          ),

        const SizedBox(height: 12),

        // Cancel button
        OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => _showCancelDialog(context, ref, order.id!),
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel Order'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD20F39), // red
            side: const BorderSide(color: Color(0xFFD20F39)),
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
      WidgetRef ref, String orderId, String newStatus) async {
    await ref
        .read(orderActionsProvider.notifier)
        .updateOrderStatus(orderId, newStatus);
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for cancellation:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Customer request, Out of stock',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD20F39),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      await ref
          .read(orderActionsProvider.notifier)
          .cancelOrder(orderId, reasonController.text.trim());
    }
  }
}
