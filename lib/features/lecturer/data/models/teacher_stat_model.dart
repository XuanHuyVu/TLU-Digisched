import '../../domain/entities/teacher_stat_entity.dart';

class TeacherStatModel extends TeacherStatEntity {
  const TeacherStatModel({
    required super.teacherId,
    required super.teacherName,
    required super.semesterId,
    required super.semesterName,
    required super.taughtHours,
    required super.notTaughtHours,
    required super.makeUpHours,
    required super.totalHours,
  });

  factory TeacherStatModel.fromJson(Map<String, dynamic> json) {
    return TeacherStatModel(
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      semesterId: json['semesterId'],
      semesterName: json['semesterName'],
      taughtHours: (json['taughtHours'] as num).toDouble(),
      notTaughtHours: (json['notTaughtHours'] as num).toDouble(),
      makeUpHours: (json['makeUpHours'] as num).toDouble(),
      totalHours: (json['totalHours'] as num).toDouble(),
    );
  }
}
