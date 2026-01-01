import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/notification_service.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please login')),
      );
    }

    final notificationsAsync = ref.watch(userNotificationsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              final unreadCount =
                  notifications.where((n) => !n.isRead).length;
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    final service = ref.read(notificationServiceProvider);
                    await service.markAllAsRead(user.id);
                    ref.invalidate(userNotificationsProvider(user.id));
                    ref.invalidate(unreadNotificationCountProvider(user.id));
                  },
                  child: const Text('Mark all as read'),
                );
              }
              return const SizedBox();
            },
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userNotificationsProvider(user.id));
              ref.invalidate(unreadNotificationCountProvider(user.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      final service = ref.read(notificationServiceProvider);
                      await service.markAsRead(notification.id);
                      ref.invalidate(userNotificationsProvider(user.id));
                      ref.invalidate(unreadNotificationCountProvider(user.id));
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.isRead ? null : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey[300]
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            _getIcon(notification.type),
            color: notification.isRead ? Colors.grey[600] : Colors.white,
          ),
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(notification.date),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'adoption_status':
        return Icons.check_circle;
      case 'application_received':
        return Icons.description;
      case 'application_submitted':
        return Icons.send;
      default:
        return Icons.notifications;
    }
  }
}

