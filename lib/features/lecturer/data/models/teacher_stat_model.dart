import '../../domain/entities/teacher_stat_entity.dart';

class TeacherStatModel extends TeacherStatEntity {
  const TeacherStatModel({
    required int teacherId,
    required String teacherName,
    required int semesterId,
    required String semesterName,
    required double taughtHours,
    required double notTaughtHours,
    required double makeUpHours,
    required double totalHours,
  }) : super(
         teacherId: teacherId,
         teacherName: teacherName,
         semesterId: semesterId,
         semesterName: semesterName,
         taughtHours: taughtHours,
         notTaughtHours: notTaughtHours,
         makeUpHours: makeUpHours,
         totalHours: totalHours,
       );

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
