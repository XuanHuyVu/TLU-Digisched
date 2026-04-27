// lib/features/teacher/models/teacher_model.dart
class TeacherModel {
  final int id;
  final String name;
  final String faculty;
  final String? department;   // có thể null nếu API không trả về
  final String? avatarUrl;    // có thể null, dùng để hiển thị avt hoặc chữ viết tắt

  const TeacherModel({
    required this.id,
    required this.name,
    required this.faculty,
    this.department,
    this.avatarUrl,
  });

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
