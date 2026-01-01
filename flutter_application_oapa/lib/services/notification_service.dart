import '../models/notification.dart';

class NotificationService {
  final List<AppNotification> _notifications = [];

  Future<AppNotification> createNotification({
    required String userId,
    required String message,
    String? type,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      date: DateTime.now(),
      isRead: false,
      type: type,
    );

    _notifications.add(notification);
    return notification;
  }

  Future<List<AppNotification>> getUserNotifications(String userId) async {
    return _notifications
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<int> getUnreadCount(String userId) async {
    return _notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }
}

