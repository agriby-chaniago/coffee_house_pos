import 'package:intl/intl.dart';

class DateFormatter {
  /// Format DateTime to readable string (e.g., "21 Nov 2025, 14:30")
  static String format(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(dateTime);
  }

  /// Format DateTime to date only (e.g., "21 Nov 2025")
  static String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  /// Format DateTime to time only (e.g., "14:30")
  static String formatTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Format DateTime to order number format (e.g., "20251121")
  static String formatForOrderNumber(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyyMMdd');
    return formatter.format(dateTime);
  }

  /// Check if two dates are same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
