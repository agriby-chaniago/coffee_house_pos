import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'offline_queue_item_model.freezed.dart';
part 'offline_queue_item_model.g.dart';

enum OfflineOperationType {
  create,
  update,
  delete,
}

@freezed
@HiveType(typeId: 1)
class OfflineQueueItem with _$OfflineQueueItem {
  const factory OfflineQueueItem({
    @HiveField(0) required String id,
    @HiveField(1) required OfflineOperationType operationType,
    @HiveField(2) required String collectionName,
    @HiveField(3) required Map<String, dynamic> data,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) @Default(0) int retryCount,
    @HiveField(6) String? lastError,
  }) = _OfflineQueueItem;

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) =>
      _$OfflineQueueItemFromJson(json);
}
