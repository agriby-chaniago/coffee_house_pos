enum OperationType {
  create,
  update,
  delete,
}

class OfflineQueueItem {
  final String id;
  final OperationType operationType;
  final String collectionName;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const OfflineQueueItem({
    required this.id,
    required this.operationType,
    required this.collectionName,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  factory OfflineQueueItem.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItem(
      id: json['id'] as String,
      operationType: OperationType.values.firstWhere(
        (e) => e.name == json['operationType'],
        orElse: () => OperationType.create,
      ),
      collectionName: json['collectionName'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationType': operationType.name,
      'collectionName': collectionName,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  bool get canRetry => retryCount < 3;

  OfflineQueueItem incrementRetry(String error) {
    return OfflineQueueItem(
      id: id,
      operationType: operationType,
      collectionName: collectionName,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
      lastError: error,
    );
  }

  OfflineQueueItem copyWith({
    String? id,
    OperationType? operationType,
    String? collectionName,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return OfflineQueueItem(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      collectionName: collectionName ?? this.collectionName,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
