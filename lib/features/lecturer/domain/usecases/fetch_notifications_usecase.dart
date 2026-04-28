import '../entities/notification_entity.dart';
import '../repositories/teacher_notification_repository.dart';

class FetchNotificationsUseCase {
  final TeacherNotificationRepository repository;

  FetchNotificationsUseCase({required this.repository});

  Future<List<NotificationEntity>> call() {
    return repository.fetchNotifications();
  }
}
