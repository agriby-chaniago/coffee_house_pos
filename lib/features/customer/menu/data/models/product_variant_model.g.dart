// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      stockUsagePerUnit: (json['stockUsagePerUnit'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
        _$ProductVariantImpl instance) =>
    <String, dynamic>{
      'size': instance.size,
      'price': instance.price,
      'stockUsagePerUnit': instance.stockUsagePerUnit,
    };
