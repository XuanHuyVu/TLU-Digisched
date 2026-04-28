import '../repositories/teacher_notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final TeacherNotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  Future<void> call(int notificationId) {
    return repository.markAsRead(notificationId);
  }
}
