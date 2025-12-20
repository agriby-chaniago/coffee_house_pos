import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// Notification model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    // Safely convert data field to Map<String, dynamic>
    Map<String, dynamic>? dataMap;
    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        dataMap = json['data'] as Map<String, dynamic>;
      } else if (json['data'] is Map) {
        dataMap = Map<String, dynamic>.from(json['data'] as Map);
      }
    }

    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.system,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: dataMap,
    );
  }
}

enum NotificationType {
  orderUpdate,
  orderReady,
  orderCompleted,
  orderCancelled,
  promotion,
  system,
}

// Notifications provider with Hive storage
class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final box = await Hive.openBox('notifications');
      final notificationsData = box.get('items', defaultValue: []) as List;

      final notifications = notificationsData.map((item) {
        // Handle both Map<dynamic, dynamic> and Map<String, dynamic>
        final map = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        return NotificationItem.fromJson(map);
      }).toList();

      // Sort by timestamp (newest first)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state = notifications;
    } catch (e) {
      print('❌ Error loading notifications: $e');
      state = [];
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final box = await Hive.openBox('notifications');
      final notificationsJson = state.map((n) => n.toJson()).toList();
      await box.put('items', notificationsJson);
    } catch (e) {
      print('❌ Error saving notifications: $e');
    }
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );

    state = [notification, ...state];
    _saveNotifications();
    print('✅ Added notification: $title');
  }

  void markAsRead(String notificationId) {
    state = [
      for (final notif in state)
        if (notif.id == notificationId) notif.copyWith(isRead: true) else notif,
    ];
    _saveNotifications();
  }

  void markAllAsRead() {
    state = [
      for (final notif in state) notif.copyWith(isRead: true),
    ];
    _saveNotifications();
  }

  void deleteNotification(String notificationId) {
    state = state.where((notif) => notif.id != notificationId).toList();
    _saveNotifications();
  }

  void clearAll() {
    state = [];
    _saveNotifications();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});
