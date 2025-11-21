// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_queue_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineQueueItemAdapter extends TypeAdapter<OfflineQueueItem> {
  @override
  final int typeId = 1;

  @override
  OfflineQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineQueueItem(
      id: fields[0] as String,
      operationType: fields[1] as OfflineOperationType,
      collectionName: fields[2] as String,
      data: (fields[3] as Map).cast<String, dynamic>(),
      createdAt: fields[4] as DateTime,
      retryCount: fields[5] as int,
      lastError: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineQueueItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationType)
      ..writeByte(2)
      ..write(obj.collectionName)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfflineQueueItemImpl _$$OfflineQueueItemImplFromJson(
        Map<String, dynamic> json) =>
    _$OfflineQueueItemImpl(
      id: json['id'] as String,
      operationType:
          $enumDecode(_$OfflineOperationTypeEnumMap, json['operationType']),
      collectionName: json['collectionName'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );

Map<String, dynamic> _$$OfflineQueueItemImplToJson(
        _$OfflineQueueItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operationType': _$OfflineOperationTypeEnumMap[instance.operationType]!,
      'collectionName': instance.collectionName,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'retryCount': instance.retryCount,
      'lastError': instance.lastError,
    };

const _$OfflineOperationTypeEnumMap = {
  OfflineOperationType.create: 'create',
  OfflineOperationType.update: 'update',
  OfflineOperationType.delete: 'delete',
};
