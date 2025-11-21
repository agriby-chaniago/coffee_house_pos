// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_addon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SelectedAddOnImpl _$$SelectedAddOnImplFromJson(Map<String, dynamic> json) =>
    _$SelectedAddOnImpl(
      addOnId: json['addOnId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      additionalPrice: (json['additionalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$SelectedAddOnImplToJson(_$SelectedAddOnImpl instance) =>
    <String, dynamic>{
      'addOnId': instance.addOnId,
      'name': instance.name,
      'category': instance.category,
      'additionalPrice': instance.additionalPrice,
    };
