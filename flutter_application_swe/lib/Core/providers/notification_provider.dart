import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final userNotificationsProvider = FutureProvider.family<List<NotificationModel>, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsByUser(userId);
});

final unreadNotificationCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

