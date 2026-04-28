import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/teacher_notification_repository.dart';
import '../datasources/teacher_notification_remote_datasource.dart';
import '../models/notification_model.dart';

class TeacherNotificationRepositoryImpl
    implements TeacherNotificationRepository {
  final TeacherNotificationRemoteDataSource remoteDataSource;

  TeacherNotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> fetchNotifications() async {
    try {
      final data = await remoteDataSource.fetchNotifications();
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải thông báo: $e');
    }
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }
}
