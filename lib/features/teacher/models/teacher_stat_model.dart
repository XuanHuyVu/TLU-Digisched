class TeacherStat {
  final int teacherId;
  final String teacherName;
  final int semesterId;
  final String semesterName;
  final double taughtHours;
  final double notTaughtHours;
  final double makeUpHours;
  final double totalHours;

  TeacherStat({
    required this.teacherId,
    required this.teacherName,
    required this.semesterId,
    required this.semesterName,
    required this.taughtHours,
    required this.notTaughtHours,
    required this.makeUpHours,
    required this.totalHours,
  });

  factory TeacherStat.fromJson(Map<String, dynamic> json) {
    return TeacherStat(
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
