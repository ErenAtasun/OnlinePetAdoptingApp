import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';
  final _uuid = const Uuid();

  Future<NotificationModel> createNotification({
    required String userId,
    required String message,
    String? type,
  }) async {
    final notification = NotificationModel(
      id: _uuid.v4(),
      userId: userId,
      message: message,
      date: DateTime.now(),
      isRead: false,
      type: type,
    );

    final notifications = await getAllNotifications();
    notifications.add(notification);
    await _saveNotifications(notifications);

    return notification;
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey);
    
    if (notificationsJson == null) {
      return [];
    }

    final List<dynamic> notificationsList = jsonDecode(notificationsJson) as List;
    return notificationsList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    final notifications = await getAllNotifications();
    return notifications
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<int> getUnreadCount(String userId) async {
    final notifications = await getNotificationsByUser(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    final notifications = await getAllNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications(notifications);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final notifications = await getAllNotifications();
    
    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i].userId == userId && !notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    
    await _saveNotifications(notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getAllNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications(notifications);
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey,
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }
}

