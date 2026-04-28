import '../entities/notification_entity.dart';

abstract class TeacherNotificationRepository {
  Future<List<NotificationEntity>> fetchNotifications();
  Future<void> markAsRead(int notificationId);
}
