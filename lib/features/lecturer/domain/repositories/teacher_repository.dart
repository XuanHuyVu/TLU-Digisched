import '../entities/teacher_home_data_entity.dart';

abstract class TeacherRepository {
  Future<TeacherHomeDataEntity> fetchHomeData();
  Future<void> markScheduleAsDone(int scheduleDetailId);
  Future<void> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  });
}
