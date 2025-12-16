// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String?,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      amount: (json['amount'] as num).toDouble(),
      stockUnit: json['stockUnit'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      performedBy: json['performedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'productId': instance.productId,
      'productName': instance.productName,
      'amount': instance.amount,
      'stockUnit': instance.stockUnit,
      'type': instance.type,
      'reason': instance.reason,
      'notes': instance.notes,
      'performedBy': instance.performedBy,
      'timestamp': instance.timestamp.toIso8601String(),
    };
