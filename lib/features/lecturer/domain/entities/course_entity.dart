class CourseEntity {
  final int id;
  final String courseName;
  final String classCode;
  final int credits;
  final String sessionType;
  final int totalSessions;
  final int completedSessions;
  final double progressPercentage;
  final String status;
  final String? phaseName;
  final DateTime? phaseStartDate;
  final DateTime? phaseEndDate;

  CourseEntity({
    required this.id,
    required this.courseName,
    required this.classCode,
    required this.credits,
    required this.sessionType,
    required this.totalSessions,
    required this.completedSessions,
    required this.progressPercentage,
    required this.status,
    this.phaseName,
    this.phaseStartDate,
    this.phaseEndDate,
  });

  bool get isCompleted => status == 'completed';
  bool get isOngoing => status == 'ongoing';
}
