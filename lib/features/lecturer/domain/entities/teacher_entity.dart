class TeacherEntity {
  final int id;
  final String name;
  final String faculty;
  final String? department;
  final String? avatarUrl;

  const TeacherEntity({
    required this.id,
    required this.name,
    required this.faculty,
    this.department,
    this.avatarUrl,
  });
}
