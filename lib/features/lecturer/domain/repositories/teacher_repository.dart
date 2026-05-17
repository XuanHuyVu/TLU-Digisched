import '../entities/schedule_entity.dart';
import '../entities/teacher_home_data_entity.dart';

abstract class TeacherRepository {
  Future<TeacherHomeDataEntity> fetchHomeData();
  Future<List<ScheduleEntity>> fetchAllSchedules();
  Future<void> markScheduleAsDone(int scheduleDetailId);
  Future<void> markMakeupAttendance({
    required int scheduleDetailId,
    required String reason,
    String? fileUrl,
  });
  Future<void> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  });
}
