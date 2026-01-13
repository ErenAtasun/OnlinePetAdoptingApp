import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_oapa/services/notification_service.dart';

void main() {
  final notificationService = NotificationService();

  setUp(() {
    notificationService.reset();
  });

  group('createNotification', () {
    test('creates notification with required fields', () async {
      final notification = await notificationService.createNotification(
        userId: 'user-1',
        message: 'Test notification message',
      );

      expect(notification.userId, 'user-1');
      expect(notification.message, 'Test notification message');
      expect(notification.isRead, isFalse);
      expect(notification.id, isNotEmpty);
    });

    test('creates notification with optional type', () async {
      final notification = await notificationService.createNotification(
        userId: 'user-1',
        message: 'Adoption approved',
        type: 'adoption_status',
      );

      expect(notification.type, 'adoption_status');
    });

    test('adds notification to the list', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'First notification',
      );
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Second notification',
      );

      expect(notificationService.notifications.length, 2);
    });
  });

  group('getUserNotifications', () {
    test('returns only notifications for specified user', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Notification for user 1',
      );
      await notificationService.createNotification(
        userId: 'user-2',
        message: 'Notification for user 2',
      );
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Another notification for user 1',
      );

      final userNotifications =
          await notificationService.getUserNotifications('user-1');

      expect(userNotifications.length, 2);
      expect(
          userNotifications.every((n) => n.userId == 'user-1'), isTrue);
    });

    test('returns empty list for user with no notifications', () async {
      final userNotifications =
          await notificationService.getUserNotifications('nonexistent-user');

      expect(userNotifications, isEmpty);
    });

    test('returns notifications sorted by date descending', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'First',
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Second',
      );

      final notifications =
          await notificationService.getUserNotifications('user-1');

      expect(notifications.first.message, 'Second');
      expect(notifications.last.message, 'First');
    });
  });

  group('getUnreadCount', () {
    test('returns correct count of unread notifications', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Unread 1',
      );
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Unread 2',
      );

      final count = await notificationService.getUnreadCount('user-1');

      expect(count, 2);
    });

    test('returns zero for user with no notifications', () async {
      final count = await notificationService.getUnreadCount('nonexistent');

      expect(count, 0);
    });
  });

  group('markAsRead', () {
    test('marks specific notification as read', () async {
      final notification = await notificationService.createNotification(
        userId: 'user-1',
        message: 'Test notification',
      );

      await notificationService.markAsRead(notification.id);

      final updated = notificationService.notifications
          .firstWhere((n) => n.id == notification.id);
      expect(updated.isRead, isTrue);
    });

    test('does not affect other notifications', () async {
      final notification1 = await notificationService.createNotification(
        userId: 'user-1',
        message: 'First',
      );
      await Future.delayed(const Duration(milliseconds: 5));
      final notification2 = await notificationService.createNotification(
        userId: 'user-1',
        message: 'Second',
      );

      await notificationService.markAsRead(notification1.id);

      final unreadCount = await notificationService.getUnreadCount('user-1');
      expect(unreadCount, 1);

      // Verify the first notification is marked as read
      final first = notificationService.notifications
          .firstWhere((n) => n.id == notification1.id);
      expect(first.isRead, isTrue);

      // Verify the second notification is still unread
      final second = notificationService.notifications
          .firstWhere((n) => n.id == notification2.id);
      expect(second.isRead, isFalse);
    });
  });

  group('markAllAsRead', () {
    test('marks all notifications for user as read', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'First',
      );
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Second',
      );

      await notificationService.markAllAsRead('user-1');

      final unreadCount = await notificationService.getUnreadCount('user-1');
      expect(unreadCount, 0);
    });

    test('does not affect other users notifications', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'User 1 notification',
      );
      await notificationService.createNotification(
        userId: 'user-2',
        message: 'User 2 notification',
      );

      await notificationService.markAllAsRead('user-1');

      final user1Unread = await notificationService.getUnreadCount('user-1');
      final user2Unread = await notificationService.getUnreadCount('user-2');

      expect(user1Unread, 0);
      expect(user2Unread, 1);
    });
  });

  group('reset', () {
    test('clears all notifications', () async {
      await notificationService.createNotification(
        userId: 'user-1',
        message: 'Test',
      );

      notificationService.reset();

      expect(notificationService.notifications, isEmpty);
    });
  });
}
