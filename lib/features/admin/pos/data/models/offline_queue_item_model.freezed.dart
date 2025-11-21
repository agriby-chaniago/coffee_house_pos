// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offline_queue_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OfflineQueueItem _$OfflineQueueItemFromJson(Map<String, dynamic> json) {
  return _OfflineQueueItem.fromJson(json);
}

/// @nodoc
mixin _$OfflineQueueItem {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  OfflineOperationType get operationType => throw _privateConstructorUsedError;
  @HiveField(2)
  String get collectionName => throw _privateConstructorUsedError;
  @HiveField(3)
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(5)
  int get retryCount => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get lastError => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OfflineQueueItemCopyWith<OfflineQueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfflineQueueItemCopyWith<$Res> {
  factory $OfflineQueueItemCopyWith(
          OfflineQueueItem value, $Res Function(OfflineQueueItem) then) =
      _$OfflineQueueItemCopyWithImpl<$Res, OfflineQueueItem>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) OfflineOperationType operationType,
      @HiveField(2) String collectionName,
      @HiveField(3) Map<String, dynamic> data,
      @HiveField(4) DateTime createdAt,
      @HiveField(5) int retryCount,
      @HiveField(6) String? lastError});
}

/// @nodoc
class _$OfflineQueueItemCopyWithImpl<$Res, $Val extends OfflineQueueItem>
    implements $OfflineQueueItemCopyWith<$Res> {
  _$OfflineQueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? operationType = null,
    Object? collectionName = null,
    Object? data = null,
    Object? createdAt = null,
    Object? retryCount = null,
    Object? lastError = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      operationType: null == operationType
          ? _value.operationType
          : operationType // ignore: cast_nullable_to_non_nullable
              as OfflineOperationType,
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OfflineQueueItemImplCopyWith<$Res>
    implements $OfflineQueueItemCopyWith<$Res> {
  factory _$$OfflineQueueItemImplCopyWith(_$OfflineQueueItemImpl value,
          $Res Function(_$OfflineQueueItemImpl) then) =
      __$$OfflineQueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) OfflineOperationType operationType,
      @HiveField(2) String collectionName,
      @HiveField(3) Map<String, dynamic> data,
      @HiveField(4) DateTime createdAt,
      @HiveField(5) int retryCount,
      @HiveField(6) String? lastError});
}

/// @nodoc
class __$$OfflineQueueItemImplCopyWithImpl<$Res>
    extends _$OfflineQueueItemCopyWithImpl<$Res, _$OfflineQueueItemImpl>
    implements _$$OfflineQueueItemImplCopyWith<$Res> {
  __$$OfflineQueueItemImplCopyWithImpl(_$OfflineQueueItemImpl _value,
      $Res Function(_$OfflineQueueItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? operationType = null,
    Object? collectionName = null,
    Object? data = null,
    Object? createdAt = null,
    Object? retryCount = null,
    Object? lastError = freezed,
  }) {
    return _then(_$OfflineQueueItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      operationType: null == operationType
          ? _value.operationType
          : operationType // ignore: cast_nullable_to_non_nullable
              as OfflineOperationType,
      collectionName: null == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastError: freezed == lastError
          ? _value.lastError
          : lastError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OfflineQueueItemImpl implements _OfflineQueueItem {
  const _$OfflineQueueItemImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.operationType,
      @HiveField(2) required this.collectionName,
      @HiveField(3) required final Map<String, dynamic> data,
      @HiveField(4) required this.createdAt,
      @HiveField(5) this.retryCount = 0,
      @HiveField(6) this.lastError})
      : _data = data;

  factory _$OfflineQueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfflineQueueItemImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final OfflineOperationType operationType;
  @override
  @HiveField(2)
  final String collectionName;
  final Map<String, dynamic> _data;
  @override
  @HiveField(3)
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  @HiveField(4)
  final DateTime createdAt;
  @override
  @JsonKey()
  @HiveField(5)
  final int retryCount;
  @override
  @HiveField(6)
  final String? lastError;

  @override
  String toString() {
    return 'OfflineQueueItem(id: $id, operationType: $operationType, collectionName: $collectionName, data: $data, createdAt: $createdAt, retryCount: $retryCount, lastError: $lastError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfflineQueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.operationType, operationType) ||
                other.operationType == operationType) &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      operationType,
      collectionName,
      const DeepCollectionEquality().hash(_data),
      createdAt,
      retryCount,
      lastError);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OfflineQueueItemImplCopyWith<_$OfflineQueueItemImpl> get copyWith =>
      __$$OfflineQueueItemImplCopyWithImpl<_$OfflineQueueItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfflineQueueItemImplToJson(
      this,
    );
  }
}

abstract class _OfflineQueueItem implements OfflineQueueItem {
  const factory _OfflineQueueItem(
      {@HiveField(0) required final String id,
      @HiveField(1) required final OfflineOperationType operationType,
      @HiveField(2) required final String collectionName,
      @HiveField(3) required final Map<String, dynamic> data,
      @HiveField(4) required final DateTime createdAt,
      @HiveField(5) final int retryCount,
      @HiveField(6) final String? lastError}) = _$OfflineQueueItemImpl;

  factory _OfflineQueueItem.fromJson(Map<String, dynamic> json) =
      _$OfflineQueueItemImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  OfflineOperationType get operationType;
  @override
  @HiveField(2)
  String get collectionName;
  @override
  @HiveField(3)
  Map<String, dynamic> get data;
  @override
  @HiveField(4)
  DateTime get createdAt;
  @override
  @HiveField(5)
  int get retryCount;
  @override
  @HiveField(6)
  String? get lastError;
  @override
  @JsonKey(ignore: true)
  _$$OfflineQueueItemImplCopyWith<_$OfflineQueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
