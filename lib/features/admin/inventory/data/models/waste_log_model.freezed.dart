// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waste_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WasteLog _$WasteLogFromJson(Map<String, dynamic> json) {
  return _WasteLog.fromJson(json);
}

/// @nodoc
mixin _$WasteLog {
  String? get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get stockUnit => throw _privateConstructorUsedError;
  String get reason =>
      throw _privateConstructorUsedError; // Store as string for AppWrite
  String? get notes => throw _privateConstructorUsedError;
  String get loggedBy => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WasteLogCopyWith<WasteLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WasteLogCopyWith<$Res> {
  factory $WasteLogCopyWith(WasteLog value, $Res Function(WasteLog) then) =
      _$WasteLogCopyWithImpl<$Res, WasteLog>;
  @useResult
  $Res call(
      {String? id,
      String productId,
      String productName,
      double amount,
      String stockUnit,
      String reason,
      String? notes,
      String loggedBy,
      DateTime timestamp});
}

/// @nodoc
class _$WasteLogCopyWithImpl<$Res, $Val extends WasteLog>
    implements $WasteLogCopyWith<$Res> {
  _$WasteLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? productId = null,
    Object? productName = null,
    Object? amount = null,
    Object? stockUnit = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? loggedBy = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      stockUnit: null == stockUnit
          ? _value.stockUnit
          : stockUnit // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      loggedBy: null == loggedBy
          ? _value.loggedBy
          : loggedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WasteLogImplCopyWith<$Res>
    implements $WasteLogCopyWith<$Res> {
  factory _$$WasteLogImplCopyWith(
          _$WasteLogImpl value, $Res Function(_$WasteLogImpl) then) =
      __$$WasteLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String productId,
      String productName,
      double amount,
      String stockUnit,
      String reason,
      String? notes,
      String loggedBy,
      DateTime timestamp});
}

/// @nodoc
class __$$WasteLogImplCopyWithImpl<$Res>
    extends _$WasteLogCopyWithImpl<$Res, _$WasteLogImpl>
    implements _$$WasteLogImplCopyWith<$Res> {
  __$$WasteLogImplCopyWithImpl(
      _$WasteLogImpl _value, $Res Function(_$WasteLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? productId = null,
    Object? productName = null,
    Object? amount = null,
    Object? stockUnit = null,
    Object? reason = null,
    Object? notes = freezed,
    Object? loggedBy = null,
    Object? timestamp = null,
  }) {
    return _then(_$WasteLogImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      stockUnit: null == stockUnit
          ? _value.stockUnit
          : stockUnit // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      loggedBy: null == loggedBy
          ? _value.loggedBy
          : loggedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WasteLogImpl extends _WasteLog {
  const _$WasteLogImpl(
      {this.id,
      required this.productId,
      required this.productName,
      required this.amount,
      required this.stockUnit,
      required this.reason,
      this.notes,
      required this.loggedBy,
      required this.timestamp})
      : super._();

  factory _$WasteLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WasteLogImplFromJson(json);

  @override
  final String? id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final double amount;
  @override
  final String stockUnit;
  @override
  final String reason;
// Store as string for AppWrite
  @override
  final String? notes;
  @override
  final String loggedBy;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'WasteLog(id: $id, productId: $productId, productName: $productName, amount: $amount, stockUnit: $stockUnit, reason: $reason, notes: $notes, loggedBy: $loggedBy, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WasteLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.stockUnit, stockUnit) ||
                other.stockUnit == stockUnit) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.loggedBy, loggedBy) ||
                other.loggedBy == loggedBy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId, productName,
      amount, stockUnit, reason, notes, loggedBy, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WasteLogImplCopyWith<_$WasteLogImpl> get copyWith =>
      __$$WasteLogImplCopyWithImpl<_$WasteLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WasteLogImplToJson(
      this,
    );
  }
}

abstract class _WasteLog extends WasteLog {
  const factory _WasteLog(
      {final String? id,
      required final String productId,
      required final String productName,
      required final double amount,
      required final String stockUnit,
      required final String reason,
      final String? notes,
      required final String loggedBy,
      required final DateTime timestamp}) = _$WasteLogImpl;
  const _WasteLog._() : super._();

  factory _WasteLog.fromJson(Map<String, dynamic> json) =
      _$WasteLogImpl.fromJson;

  @override
  String? get id;
  @override
  String get productId;
  @override
  String get productName;
  @override
  double get amount;
  @override
  String get stockUnit;
  @override
  String get reason;
  @override // Store as string for AppWrite
  String? get notes;
  @override
  String get loggedBy;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$WasteLogImplCopyWith<_$WasteLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
