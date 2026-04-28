import '../../domain/entities/teacher_entity.dart';

class TeacherModel extends TeacherEntity {
  const TeacherModel({
    required int id,
    required String name,
    required String faculty,
    String? department,
    String? avatarUrl,
  }) : super(
         id: id,
         name: name,
         faculty: faculty,
         department: department,
         avatarUrl: avatarUrl,
       );

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      faculty: json['faculty'] ?? '',
      department: json['department'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
