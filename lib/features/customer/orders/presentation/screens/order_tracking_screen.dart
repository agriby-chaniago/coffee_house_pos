import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/order_realtime_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import 'package:coffee_house_pos/core/utils/currency_formatter.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  String? _previousStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderAsync = ref.watch(orderRealtimeProvider(widget.orderId));

    // Listen for status changes
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      orderRealtimeProvider(widget.orderId),
      (previous, next) {
        next.whenData((orderData) {
          final currentStatus = orderData['status'] as String?;
          final orderNumber = orderData['orderNumber'] as String?;

          // Show notification when order is cancelled
          if (_previousStatus != null &&
              _previousStatus != 'cancelled' &&
              currentStatus == 'cancelled') {
            HapticFeedback.mediumImpact();

            // Add notification
            ref.read(notificationsProvider.notifier).addNotification(
              title: 'Pesanan Dibatalkan',
              message: 'Pesanan #$orderNumber telah dibatalkan',
              type: NotificationType.orderCancelled,
              data: {'orderId': widget.orderId, 'orderNumber': orderNumber},
            );

            _showCancelledDialog(
              context,
              orderData['cancellationReason'] as String?,
            );
          }

          // Show notification when order is preparing
          if (_previousStatus != null &&
              _previousStatus == 'pending' &&
              currentStatus == 'preparing') {
            ref.read(notificationsProvider.notifier).addNotification(
              title: 'Pesanan Diproses',
              message: 'Pesanan #$orderNumber sedang diproses',
              type: NotificationType.orderUpdate,
              data: {'orderId': widget.orderId, 'orderNumber': orderNumber},
            );
          }

          // Show notification when order is ready
          if (_previousStatus != null &&
              _previousStatus != 'ready' &&
              currentStatus == 'ready') {
            HapticFeedback.mediumImpact();

            // Add notification
            ref.read(notificationsProvider.notifier).addNotification(
              title: '🎉 Pesanan Siap!',
              message: 'Pesanan #$orderNumber sudah siap diambil',
              type: NotificationType.orderReady,
              data: {'orderId': widget.orderId, 'orderNumber': orderNumber},
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Pesanan Anda sudah siap!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }

          // Show notification when order is completed
          if (_previousStatus != null &&
              _previousStatus != 'completed' &&
              currentStatus == 'completed') {
            ref.read(notificationsProvider.notifier).addNotification(
              title: 'Pesanan Selesai',
              message: 'Terima kasih atas pesanan #$orderNumber!',
              type: NotificationType.orderCompleted,
              data: {'orderId': widget.orderId, 'orderNumber': orderNumber},
            );
          }

          _previousStatus = currentStatus;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to menu (home)
            context.go('/customer/menu');
          },
        ),
        title: const Text('Order Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(orderRealtimeProvider(widget.orderId));
            },
          ),
        ],
      ),
      body: orderAsync.when(
        data: (orderData) => _buildContent(context, theme, orderData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              const Text('Failed to load order'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(orderRealtimeProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelledDialog(BuildContext context, String? reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.cancel_outlined,
          size: 64,
          color: Colors.red,
        ),
        title: const Text('Pesanan Dibatalkan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mohon maaf, pesanan Anda telah dibatalkan oleh admin.',
              textAlign: TextAlign.center,
            ),
            if (reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alasan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/customer/menu');
            },
            child: const Text('Kembali ke Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ThemeData theme, Map<String, dynamic> orderData) {
    final status = orderData['status'] as String? ?? 'pending';
    final orderNumber = orderData['orderNumber'] as String? ?? 'N/A';
    final createdAt = orderData['createdAt'] as String?;
    final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;

    // Parse items from JSON string
    List items = [];
    try {
      if (orderData['items'] is String) {
        items = jsonDecode(orderData['items']) as List;
      } else if (orderData['items'] is List) {
        items = orderData['items'] as List;
      }
    } catch (e) {
      print('Error parsing items: $e');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Number Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Order Number',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '#$orderNumber',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: orderNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order number copied!'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • HH:mm')
                          .format(DateTime.parse(createdAt)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Status Stepper
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusStepper(theme, status),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Order Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) {
                    final itemData = item as Map<String, dynamic>;
                    final productName = itemData['productName'] ?? '';
                    final quantity = itemData['quantity'] ?? 1;
                    final size = itemData['size'] ?? '';
                    final addons = itemData['addons'] as List? ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${quantity}x',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Size: $size',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (addons.isNotEmpty)
                                  Text(
                                    'Add-ons: ${addons.map((a) => a['name']).join(", ")}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(total),
                        style: theme.textTheme.titleLarge?.copyWith(
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

          const SizedBox(height: 24),

          // Help Card
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Contact staff at counter',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(ThemeData theme, String currentStatus) {
    final statuses = ['pending', 'preparing', 'ready', 'completed'];
    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        final isActive = index == currentIndex;
        final isLast = index == statuses.length - 1;

        final statusColor = Color(orderStatusColors[status] ?? 0xFF9399B2);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? statusColor
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: isCompleted
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? statusColor
                        : theme.colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(status),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? statusColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getEstimatedTime(status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
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
        return 'Order Received';
      case 'preparing':
        return 'Being Prepared';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
