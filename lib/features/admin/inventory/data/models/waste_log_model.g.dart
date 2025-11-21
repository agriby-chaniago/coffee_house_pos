// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WasteLogImpl _$$WasteLogImplFromJson(Map<String, dynamic> json) =>
    _$WasteLogImpl(
      id: json['id'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      amount: (json['amount'] as num).toDouble(),
      stockUnit: json['stockUnit'] as String,
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      loggedBy: json['loggedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$WasteLogImplToJson(_$WasteLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'amount': instance.amount,
      'stockUnit': instance.stockUnit,
      'reason': instance.reason,
      'notes': instance.notes,
      'loggedBy': instance.loggedBy,
      'timestamp': instance.timestamp.toIso8601String(),
    };
