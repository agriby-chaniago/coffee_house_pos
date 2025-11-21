import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../cart/data/models/order_item_model.dart';

part 'order_model.freezed.dart';

@freezed
class Order with _$Order {
  const Order._();

  const factory Order({
    String? id,
    required String orderNumber,
    String? customerId,
    String? customerName,
    required List<OrderItem> items,
    required double subtotal,
    required double taxAmount,
    required double taxRate,
    required double total,
    required String status, // Store as string for AppWrite
    String? paymentMethod, // Store as string for AppWrite
    required String cashierId,
    required String cashierName,
    required DateTime createdAt,
    DateTime? completedAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) {
    // Handle Appwrite $id field
    String? id;
    if (json.containsKey('\$id')) {
      id = json['\$id'];
    }

    // Handle items parsing from JSON string if needed
    List<OrderItem> items;
    if (json['items'] is String) {
      items = (jsonDecode(json['items']) as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      items = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle timestamps - AppWrite uses $createdAt/$updatedAt
    DateTime createdAt;
    if (json.containsKey('\$createdAt')) {
      createdAt = DateTime.parse(json['\$createdAt']);
    } else if (json.containsKey('createdAt')) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    if (json.containsKey('\$updatedAt')) {
      updatedAt = DateTime.parse(json['\$updatedAt']);
    } else if (json.containsKey('updatedAt')) {
      updatedAt = DateTime.parse(json['updatedAt']);
    } else {
      updatedAt = DateTime.now();
    }

    return Order(
      id: id,
      orderNumber: json['orderNumber'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      items: items,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      cashierId: json['cashierId'],
      cashierName: json['cashierName'] ?? 'Unknown', // Fallback for old data
      createdAt: createdAt,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      updatedAt: updatedAt,
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Custom toJson for local storage (Hive)
  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'taxRate': taxRate,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Custom toJson for AppWrite
  Map<String, dynamic> toAppwriteJson() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'items': jsonEncode(items.map((item) => item.toJson()).toList()),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'taxRate': taxRate,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'cashierId': cashierId,
      'completedAt': completedAt?.toIso8601String(),
      // AppWrite will auto-generate $createdAt and $updatedAt
      // Don't send cashierName, createdAt, updatedAt (not in your schema)
    };
  }
}

extension OrderExtension on Order {
  OrderStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  PaymentMethod? get paymentMethodEnum {
    if (paymentMethod == null) return null;
    switch (paymentMethod!.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'qris':
        return PaymentMethod.qris;
      case 'debit':
        return PaymentMethod.debit;
      case 'credit':
        return PaymentMethod.credit;
      default:
        return null;
    }
  }
}
