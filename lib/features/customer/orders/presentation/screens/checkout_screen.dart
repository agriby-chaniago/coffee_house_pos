import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/checkout_provider.dart';
import '../../../cart/presentation/providers/customer_cart_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

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
            notes: _notesController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(customerCartProvider);
    final checkoutState = ref.watch(checkoutProvider);

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
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.status == CheckoutStatus.error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Terjadi kesalahan'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
              const Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: AppTheme.peach,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(
                      fontSize: 20,
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
                  color: AppTheme.mantle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.surface,
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
                      value: 'Rp ${cartState.subtotal.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'PPN (11%)',
                      value: 'Rp ${cartState.tax.toStringAsFixed(0)}',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Total Pembayaran',
                      value: 'Rp ${cartState.total.toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Customer info header
              const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppTheme.blue,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Informasi Pelanggan',
                    style: TextStyle(
                      fontSize: 20,
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
                  fillColor: AppTheme.mantle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
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
                  fillColor: AppTheme.mantle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
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

              // Notes field (optional)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan untuk pesanan',
                  prefixIcon: const Icon(Icons.note_outlined),
                  filled: true,
                  fillColor: AppTheme.mantle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surface),
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
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pesanan akan diteruskan ke dapur dan bisa dipantau statusnya',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.subtext0,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.text : AppTheme.subtext0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.green : AppTheme.text,
          ),
        ),
      ],
    );
  }
}
