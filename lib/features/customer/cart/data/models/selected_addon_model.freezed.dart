// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_addon_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SelectedAddOn _$SelectedAddOnFromJson(Map<String, dynamic> json) {
  return _SelectedAddOn.fromJson(json);
}

/// @nodoc
mixin _$SelectedAddOn {
  String get addOnId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get additionalPrice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SelectedAddOnCopyWith<SelectedAddOn> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedAddOnCopyWith<$Res> {
  factory $SelectedAddOnCopyWith(
          SelectedAddOn value, $Res Function(SelectedAddOn) then) =
      _$SelectedAddOnCopyWithImpl<$Res, SelectedAddOn>;
  @useResult
  $Res call(
      {String addOnId, String name, String category, double additionalPrice});
}

/// @nodoc
class _$SelectedAddOnCopyWithImpl<$Res, $Val extends SelectedAddOn>
    implements $SelectedAddOnCopyWith<$Res> {
  _$SelectedAddOnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addOnId = null,
    Object? name = null,
    Object? category = null,
    Object? additionalPrice = null,
  }) {
    return _then(_value.copyWith(
      addOnId: null == addOnId
          ? _value.addOnId
          : addOnId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      additionalPrice: null == additionalPrice
          ? _value.additionalPrice
          : additionalPrice // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectedAddOnImplCopyWith<$Res>
    implements $SelectedAddOnCopyWith<$Res> {
  factory _$$SelectedAddOnImplCopyWith(
          _$SelectedAddOnImpl value, $Res Function(_$SelectedAddOnImpl) then) =
      __$$SelectedAddOnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String addOnId, String name, String category, double additionalPrice});
}

/// @nodoc
class __$$SelectedAddOnImplCopyWithImpl<$Res>
    extends _$SelectedAddOnCopyWithImpl<$Res, _$SelectedAddOnImpl>
    implements _$$SelectedAddOnImplCopyWith<$Res> {
  __$$SelectedAddOnImplCopyWithImpl(
      _$SelectedAddOnImpl _value, $Res Function(_$SelectedAddOnImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addOnId = null,
    Object? name = null,
    Object? category = null,
    Object? additionalPrice = null,
  }) {
    return _then(_$SelectedAddOnImpl(
      addOnId: null == addOnId
          ? _value.addOnId
          : addOnId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      additionalPrice: null == additionalPrice
          ? _value.additionalPrice
          : additionalPrice // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectedAddOnImpl implements _SelectedAddOn {
  const _$SelectedAddOnImpl(
      {required this.addOnId,
      required this.name,
      required this.category,
      required this.additionalPrice});

  factory _$SelectedAddOnImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedAddOnImplFromJson(json);

  @override
  final String addOnId;
  @override
  final String name;
  @override
  final String category;
  @override
  final double additionalPrice;

  @override
  String toString() {
    return 'SelectedAddOn(addOnId: $addOnId, name: $name, category: $category, additionalPrice: $additionalPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedAddOnImpl &&
            (identical(other.addOnId, addOnId) || other.addOnId == addOnId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.additionalPrice, additionalPrice) ||
                other.additionalPrice == additionalPrice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, addOnId, name, category, additionalPrice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedAddOnImplCopyWith<_$SelectedAddOnImpl> get copyWith =>
      __$$SelectedAddOnImplCopyWithImpl<_$SelectedAddOnImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedAddOnImplToJson(
      this,
    );
  }
}

abstract class _SelectedAddOn implements SelectedAddOn {
  const factory _SelectedAddOn(
      {required final String addOnId,
      required final String name,
      required final String category,
      required final double additionalPrice}) = _$SelectedAddOnImpl;

  factory _SelectedAddOn.fromJson(Map<String, dynamic> json) =
      _$SelectedAddOnImpl.fromJson;

  @override
  String get addOnId;
  @override
  String get name;
  @override
  String get category;
  @override
  double get additionalPrice;
  @override
  @JsonKey(ignore: true)
  _$$SelectedAddOnImplCopyWith<_$SelectedAddOnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
