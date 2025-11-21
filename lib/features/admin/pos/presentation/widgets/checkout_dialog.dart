import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';
import 'package:coffee_house_pos/core/services/hive_service.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import 'order_success_dialog.dart';
import 'dart:convert';
import 'package:coffee_house_pos/features/customer/orders/data/models/order_model.dart';

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
}

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final _customerNameController = TextEditingController();
  final _cashReceivedController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  double get _cashReceived {
    return double.tryParse(_cashReceivedController.text) ?? 0;
  }

  double get _change {
    final cart = ref.read(cartProvider);
    return _cashReceived - cart.total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.read(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Checkout',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer name (optional)
                    Text(
                      'Customer Name (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter customer name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment method
                    Text(
                      'Payment Method',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: PaymentMethod.values.map((method) {
                        final isSelected = _selectedPaymentMethod == method;
                        return ChoiceChip(
                          label: Text(method.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPaymentMethod = method;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Cash received (only for cash payment)
                    if (_selectedPaymentMethod == PaymentMethod.cash) ...[
                      Text(
                        'Cash Received',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cashReceivedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter amount',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      if (_cashReceived > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _change >= 0
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Change',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _change >= 0
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              Text(
                                formatCurrency(_change.abs()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _change >= 0
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_change < 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Insufficient cash received',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // Order summary
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Items', '${cart.items.length}'),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                              'Subtotal', formatCurrency(cart.subtotal)),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                              'PPN 11%', formatCurrency(cart.taxAmount)),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'Total',
                            formatCurrency(cart.total),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_selectedPaymentMethod == PaymentMethod.cash &&
                              _change < 0) ||
                          checkoutState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(checkoutProvider.notifier)
                              .processCheckout(
                                paymentMethod: _selectedPaymentMethod,
                                customerName:
                                    _customerNameController.text.trim().isEmpty
                                        ? null
                                        : _customerNameController.text.trim(),
                                cashReceived:
                                    _selectedPaymentMethod == PaymentMethod.cash
                                        ? _cashReceived
                                        : null,
                              );

                          if (success && context.mounted) {
                            Navigator.pop(context);

                            // Get the completed order
                            final orderNumber =
                                ref.read(checkoutProvider).orderId;
                            if (orderNumber != null) {
                              // Retrieve order from Hive
                              final ordersBox = HiveService.getOrdersBox();
                              final orderJson = ordersBox.get(orderNumber);

                              if (orderJson != null) {
                                final order = Order.fromJson(
                                  jsonDecode(orderJson as String),
                                );

                                // Show success dialog with print option
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) =>
                                      OrderSuccessDialog(order: order),
                                );
                              } else {
                                // Just show snackbar if order not found
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Order completed successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } else if (!success && context.mounted) {
                            // Show error
                            final error = ref.read(checkoutProvider).error;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    error?.toString() ?? 'Checkout failed'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        },
                  icon: checkoutState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    checkoutState.isLoading
                        ? 'Processing...'
                        : 'Complete Order',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
