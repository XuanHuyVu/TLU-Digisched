import '../../domain/entities/teacher_home_data_entity.dart';
import 'teacher_model.dart';
import 'schedule_model.dart';

class TeacherHomeDataModel extends TeacherHomeDataEntity {
  const TeacherHomeDataModel({
    required TeacherModel super.teacher,
    required super.periodsToday,
    required super.periodsThisWeek,
    required super.percentCompleted,
    required List<ScheduleModel> super.todaySchedules,
  });

  factory TeacherHomeDataModel.fromJson(Map<String, dynamic> json) {
    return TeacherHomeDataModel(
      teacher: TeacherModel.fromJson(json['teacher'] ?? {}),
      periodsToday: json['periodsToday'] ?? 0,
      periodsThisWeek: json['periodsThisWeek'] ?? 0,
      percentCompleted: json['percentCompleted'] ?? 0,
      todaySchedules: (json['todaySchedules'] as List?) ?.map((e) => ScheduleModel.fromJson(e)).toList() ?? [],
    );
  }
}
