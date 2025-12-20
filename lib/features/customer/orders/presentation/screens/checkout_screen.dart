import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../providers/checkout_provider.dart';
import '../../../cart/presentation/providers/customer_cart_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tableController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedPaymentMethod = 'QRIS'; // Default payment method
  bool _hasInitializedName = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      ref.read(checkoutProvider.notifier).placeOrder(
            customerName: _nameController.text.trim(),
            tableNumber: _tableController.text.trim(),
            paymentMethod: _selectedPaymentMethod,
            notes: _notesController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(customerCartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final authState = ref.watch(authStateProvider);

    // Auto-populate customer name from user's display name
    if (!_hasInitializedName && authState.hasValue) {
      authState.whenData((state) {
        if (state is AuthStateAuthenticated && _nameController.text.isEmpty) {
          _nameController.text = state.user.name;
          _hasInitializedName = true;
        }
      });
    }

    // Listen to checkout state changes
    ref.listen<CheckoutState>(checkoutProvider, (previous, next) {
      if (next.status == CheckoutStatus.success && next.orderId != null) {
        // Add notification for successful order
        ref.read(notificationsProvider.notifier).addNotification(
          title: 'Pesanan Berhasil Dibuat! ✅',
          message: 'Pesanan Anda sedang diproses',
          type: NotificationType.orderUpdate,
          data: {'orderId': next.orderId},
        );

        // Navigate to order tracking
        context.go('/customer/orders/${next.orderId}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesanan berhasil dibuat!'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        });
      } else if (next.status == CheckoutStatus.error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Terjadi kesalahan'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary header
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppTheme.peach,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ringkasan Pesanan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Order summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Total Item',
                      value: '${cartState.items.length} item',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Subtotal',
                      value: CurrencyFormatter.format(cartState.subtotal),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'PPN (11%)',
                      value: CurrencyFormatter.format(cartState.tax),
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Total Pembayaran',
                      value: CurrencyFormatter.format(cartState.total),
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Customer info header
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: AppTheme.blue,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Informasi Pelanggan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama Anda',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Table number field
              TextFormField(
                controller: _tableController,
                decoration: InputDecoration(
                  labelText: 'Nomor Meja',
                  hintText: 'Contoh: 5',
                  prefixIcon: const Icon(Icons.table_restaurant),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor meja tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: 'Metode Pembayaran',
                  prefixIcon: const Icon(Icons.payment),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                  DropdownMenuItem(value: 'Debit', child: Text('Debit Card')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Notes field (optional)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan untuk pesanan',
                  prefixIcon: const Icon(Icons.note_outlined),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                maxLines: 3,
                maxLength: 200,
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: checkoutState.status == CheckoutStatus.loading
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.green,
                    foregroundColor: AppTheme.base,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppTheme.overlay0,
                  ),
                  child: checkoutState.status == CheckoutStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text(
                              'Buat Pesanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pesanan akan diteruskan ke dapur dan bisa dipantau statusnya',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? (theme.brightness == Brightness.dark
                    ? AppTheme.green
                    : const Color(0xFF2D7A3E))
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
