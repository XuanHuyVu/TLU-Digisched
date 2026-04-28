class TeacherStatEntity {
  final int teacherId;
  final String teacherName;
  final int semesterId;
  final String semesterName;
  final double taughtHours;
  final double notTaughtHours;
  final double makeUpHours;
  final double totalHours;

  const TeacherStatEntity({
    required this.teacherId,
    required this.teacherName,
    required this.semesterId,
    required this.semesterName,
    required this.taughtHours,
    required this.notTaughtHours,
    required this.makeUpHours,
    required this.totalHours,
  });
}
