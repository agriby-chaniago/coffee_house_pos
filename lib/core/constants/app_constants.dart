class AppConstants {
  // Tax Rate
  static const double ppnRate = 0.11; // PPN Indonesia 11%

  // Product Categories (Fixed)
  static const List<String> productCategories = [
    'Coffee',
    'Non-Coffee',
    'Food',
    'Snack',
  ];

  // Stock Units
  static const List<String> stockUnits = [
    'cup',
    'slice',
    'piece',
  ];

  // Waste Reasons
  static const List<String> wasteReasons = [
    'Expired',
    'Damaged',
    'Spilled',
    'Other',
  ];

  // Add-on Categories
  static const List<String> addOnCategories = [
    'Milk Type',
    'Sugar Level',
    'Extras',
    'Ice Level',
  ];

  // Product Sizes
  static const List<String> productSizes = ['M', 'L'];

  // Analytics Date Range
  static const int maxAnalyticsDays = 30;

  // Offline Sync
  static const int maxRetryAttempts = 3;
  static const int syncIntervalSeconds = 30;

  // Image Upload
  static const int maxImageSizeBytes = 1048576; // 1MB
  static const int imageMaxWidth = 800;
  static const int imageMaxHeight = 800;
  static const int imageQuality = 85;
}

// Enums
enum OrderStatus {
  pending,
  preparing,
  ready,
  completed,
  cancelled,
}

enum PaymentMethod {
  cash,
  qris,
  debit,
  credit,
}

enum UserRole {
  customer,
  admin,
}

enum AddOnCategory {
  milkType,
  sugarLevel,
  extras,
  iceLevel,
}

enum WasteReason {
  expired,
  damaged,
  spilled,
  other,
}

enum StockUnit {
  pcs,
  kg,
  liter,
  gram,
  ml,
}

// Extension methods for enums
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.debit:
        return 'Debit Card';
      case PaymentMethod.credit:
        return 'Credit Card';
    }
  }
}

extension AddOnCategoryExtension on AddOnCategory {
  String get displayName {
    switch (this) {
      case AddOnCategory.milkType:
        return 'Milk Type';
      case AddOnCategory.sugarLevel:
        return 'Sugar Level';
      case AddOnCategory.extras:
        return 'Extras';
      case AddOnCategory.iceLevel:
        return 'Ice Level';
    }
  }
}

extension WasteReasonExtension on WasteReason {
  String get displayName {
    switch (this) {
      case WasteReason.expired:
        return 'Expired';
      case WasteReason.damaged:
        return 'Damaged';
      case WasteReason.spilled:
        return 'Spilled';
      case WasteReason.other:
        return 'Other';
    }
  }
}
