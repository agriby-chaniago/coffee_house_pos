import 'package:freezed_annotation/freezed_annotation.dart';
import 'selected_addon_model.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const OrderItem._();

  const factory OrderItem({
    required String id,
    required String productId,
    required String productName,
    required String selectedSize, // 'M' or 'L'
    required double basePrice,
    required int quantity,
    required List<SelectedAddOn> addOns,
    String? notes,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  // Calculate total price for this item
  double get itemTotal {
    final addOnsTotal = addOns.fold<double>(
      0.0,
      (sum, addon) => sum + addon.additionalPrice,
    );
    return (basePrice + addOnsTotal) * quantity;
  }
}
