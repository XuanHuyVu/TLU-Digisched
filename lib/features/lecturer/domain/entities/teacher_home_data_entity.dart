import 'teacher_entity.dart';
import 'schedule_entity.dart';

class TeacherHomeDataEntity {
  final TeacherEntity teacher;
  final int periodsToday;
  final int periodsThisWeek;
  final int percentCompleted;
  final List<ScheduleEntity> todaySchedules;

  const TeacherHomeDataEntity({
    required this.teacher,
    required this.periodsToday,
    required this.periodsThisWeek,
    required this.percentCompleted,
    required this.todaySchedules,
  });
}
