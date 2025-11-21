// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      selectedSize: json['selectedSize'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      addOns: (json['addOns'] as List<dynamic>)
          .map((e) => SelectedAddOn.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'selectedSize': instance.selectedSize,
      'basePrice': instance.basePrice,
      'quantity': instance.quantity,
      'addOns': instance.addOns,
      'notes': instance.notes,
    };
