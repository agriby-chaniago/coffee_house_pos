// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'addon_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AddOn {
  String? get id => throw _privateConstructorUsedError; // Appwrite $id
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get additionalPrice => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AddOnCopyWith<AddOn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddOnCopyWith<$Res> {
  factory $AddOnCopyWith(AddOn value, $Res Function(AddOn) then) =
      _$AddOnCopyWithImpl<$Res, AddOn>;
  @useResult
  $Res call(
      {String? id,
      String name,
      String category,
      double additionalPrice,
      bool isDefault,
      int sortOrder,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$AddOnCopyWithImpl<$Res, $Val extends AddOn>
    implements $AddOnCopyWith<$Res> {
  _$AddOnCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? category = null,
    Object? additionalPrice = null,
    Object? isDefault = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
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
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddOnImplCopyWith<$Res> implements $AddOnCopyWith<$Res> {
  factory _$$AddOnImplCopyWith(
          _$AddOnImpl value, $Res Function(_$AddOnImpl) then) =
      __$$AddOnImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String name,
      String category,
      double additionalPrice,
      bool isDefault,
      int sortOrder,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$AddOnImplCopyWithImpl<$Res>
    extends _$AddOnCopyWithImpl<$Res, _$AddOnImpl>
    implements _$$AddOnImplCopyWith<$Res> {
  __$$AddOnImplCopyWithImpl(
      _$AddOnImpl _value, $Res Function(_$AddOnImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? category = null,
    Object? additionalPrice = null,
    Object? isDefault = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$AddOnImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
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
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$AddOnImpl extends _AddOn {
  const _$AddOnImpl(
      {this.id,
      required this.name,
      required this.category,
      required this.additionalPrice,
      this.isDefault = false,
      required this.sortOrder,
      this.isActive = true,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  @override
  final String? id;
// Appwrite $id
  @override
  final String name;
  @override
  final String category;
  @override
  final double additionalPrice;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AddOn(id: $id, name: $name, category: $category, additionalPrice: $additionalPrice, isDefault: $isDefault, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddOnImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.additionalPrice, additionalPrice) ||
                other.additionalPrice == additionalPrice) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, category,
      additionalPrice, isDefault, sortOrder, isActive, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddOnImplCopyWith<_$AddOnImpl> get copyWith =>
      __$$AddOnImplCopyWithImpl<_$AddOnImpl>(this, _$identity);
}

abstract class _AddOn extends AddOn {
  const factory _AddOn(
      {final String? id,
      required final String name,
      required final String category,
      required final double additionalPrice,
      final bool isDefault,
      required final int sortOrder,
      final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$AddOnImpl;
  const _AddOn._() : super._();

  @override
  String? get id;
  @override // Appwrite $id
  String get name;
  @override
  String get category;
  @override
  double get additionalPrice;
  @override
  bool get isDefault;
  @override
  int get sortOrder;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AddOnImplCopyWith<_$AddOnImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
