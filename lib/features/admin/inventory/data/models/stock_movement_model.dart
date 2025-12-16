import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement_model.freezed.dart';
part 'stock_movement_model.g.dart';

@freezed
class StockMovement with _$StockMovement {
  const StockMovement._();

  const factory StockMovement({
    String? id,
    required String orderId,
    required String orderNumber,
    required String productId,
    required String productName,
    required double amount,
    required String stockUnit,
    required String type, // 'sale', 'restock', 'adjustment'
    String?
        reason, // For waste tracking: 'expired', 'damaged', 'spilled', 'other'
    String? notes, // Additional notes for adjustments/waste
    required String performedBy,
    required DateTime timestamp,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
}
