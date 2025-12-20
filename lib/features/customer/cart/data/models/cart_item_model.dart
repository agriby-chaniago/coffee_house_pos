import 'package:hive/hive.dart';
import '../../../../admin/inventory/data/models/addon_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 10)
class CartItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String productImage;

  @HiveField(4)
  final String size; // M or L

  @HiveField(5)
  final double price; // Base price for selected size

  @HiveField(6)
  final int quantity;

  @HiveField(7)
  final List<AddOn> addons;

  @HiveField(8)
  final String notes;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.size,
    required this.price,
    required this.quantity,
    required this.addons,
    required this.notes,
  });

  // Calculate item total (base price + addons) * quantity
  double get itemTotal {
    double addonsTotal =
        addons.fold(0, (sum, addon) => sum + addon.additionalPrice);
    return (price + addonsTotal) * quantity;
  }

  // Create copy with updated fields
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    String? size,
    double? price,
    int? quantity,
    List<AddOn>? addons,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      size: size ?? this.size,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      addons: addons ?? this.addons,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'size': size,
      'price': price,
      'quantity': quantity,
      'addons': addons.map((a) => a.toJson()).toList(),
      'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String? ?? '',
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      addons: (json['addons'] as List?)
              ?.map((a) => AddOn.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }
}
