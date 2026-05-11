class LecturerStatisticsEntity {
  final LecturerOverview overview;
  final TeachingStats teachingStats;
  final CourseStats courseStats;
  final ScheduleStats scheduleStats;
  final AdjustmentRequestStats adjustmentStats;

  const LecturerStatisticsEntity({
    required this.overview,
    required this.teachingStats,
    required this.courseStats,
    required this.scheduleStats,
    required this.adjustmentStats,
  });
}

class LecturerOverview {
  final int lecturerId;
  final String lecturerName;
  final String departmentName;
  final String academicRank;
  final String degree;
  final int totalCoursesThisSemester;
  final int totalSessionsThisSemester;
  final int completedSessions;
  final int upcomingSessions;

  const LecturerOverview({
    required this.lecturerId,
    required this.lecturerName,
    required this.departmentName,
    required this.academicRank,
    required this.degree,
    required this.totalCoursesThisSemester,
    required this.totalSessionsThisSemester,
    required this.completedSessions,
    required this.upcomingSessions,
  });
}

class TeachingStats {
  final int totalCourses;
  final int totalSessions;
  final int completedSessions;
  final int upcomingSessions;
  final int canceledSessions;
  final double completionRate;
  final List<MonthlySessionCount> monthlyTrend;

  const TeachingStats({
    required this.totalCourses,
    required this.totalSessions,
    required this.completedSessions,
    required this.upcomingSessions,
    required this.canceledSessions,
    required this.completionRate,
    required this.monthlyTrend,
  });
}

class MonthlySessionCount {
  final String month;
  final int totalSessions;
  final int completedSessions;

  const MonthlySessionCount({
    required this.month,
    required this.totalSessions,
    required this.completedSessions,
  });
}

class CourseStats {
  final int totalCourses;
  final List<CourseDetail> courses;

  const CourseStats({
    required this.totalCourses,
    required this.courses,
  });
}

class CourseDetail {
  final int courseId;
  final String courseName;
  final String courseCode;
  final String classCode;
  final int credits;
  final int totalSessions;
  final int completedSessions;
  final double completionRate;
  final String sessionType;

  const CourseDetail({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.credits,
    required this.totalSessions,
    required this.completedSessions,
    required this.completionRate,
    required this.sessionType,
  });
}

class ScheduleStats {
  final int totalScheduleDetails;
  final int completedDetails;
  final int upcomingDetails;
  final int thisWeekSessions;
  final int nextWeekSessions;
  final List<UpcomingSession> upcomingSessions;

  const ScheduleStats({
    required this.totalScheduleDetails,
    required this.completedDetails,
    required this.upcomingDetails,
    required this.thisWeekSessions,
    required this.nextWeekSessions,
    required this.upcomingSessions,
  });
}

class UpcomingSession {
  final int scheduleDetailId;
  final String courseName;
  final String classCode;
  final String sessionDate;
  final String dayOfWeek;
  final String timeRange;
  final String roomName;
  final String sessionType;

  const UpcomingSession({
    required this.scheduleDetailId,
    required this.courseName,
    required this.classCode,
    required this.sessionDate,
    required this.dayOfWeek,
    required this.timeRange,
    required this.roomName,
    required this.sessionType,
  });
}

class AdjustmentRequestStats {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final double approvalRate;
  final List<RecentRequest> recentRequests;

  const AdjustmentRequestStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.approvalRate,
    required this.recentRequests,
  });
}

class RecentRequest {
  final int requestId;
  final String courseName;
  final String classCode;
  final String reason;
  final String status;
  final String createdAt;

  const RecentRequest({
    required this.requestId,
    required this.courseName,
    required this.classCode,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
}
