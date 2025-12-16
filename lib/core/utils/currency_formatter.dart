import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format amount to IDR currency (e.g., 50000 -> "Rp 50.000")
  static String format(double amount) {
    return _idrFormatter.format(amount);
  }

  /// Format amount to IDR currency without symbol (e.g., 50000 -> "50.000")
  static String formatWithoutSymbol(double amount) {
    final NumberFormat formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount);
  }

  /// Parse IDR string to double
  static double parse(String value) {
    // Remove Rp, spaces, and dots
    final cleaned = value
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Format amount to compact IDR (e.g., 1000000 -> "Rp 1M")
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}
