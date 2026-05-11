import '../../domain/entities/lecturer_statistics_entity.dart';

class LecturerStatisticsModel extends LecturerStatisticsEntity {
  const LecturerStatisticsModel({
    required super.overview,
    required super.teachingStats,
    required super.courseStats,
    required super.scheduleStats,
    required super.adjustmentStats,
  });

  factory LecturerStatisticsModel.fromJson(Map<String, dynamic> json) {
    return LecturerStatisticsModel(
      overview: LecturerOverviewModel.fromJson(json['overview']),
      teachingStats: TeachingStatsModel.fromJson(json['teachingStats']),
      courseStats: CourseStatsModel.fromJson(json['courseStats']),
      scheduleStats: ScheduleStatsModel.fromJson(json['scheduleStats']),
      adjustmentStats: AdjustmentRequestStatsModel.fromJson(json['adjustmentStats']),
    );
  }
}

class LecturerOverviewModel extends LecturerOverview {
  const LecturerOverviewModel({
    required super.lecturerId,
    required super.lecturerName,
    required super.departmentName,
    required super.academicRank,
    required super.degree,
    required super.totalCoursesThisSemester,
    required super.totalSessionsThisSemester,
    required super.completedSessions,
    required super.upcomingSessions,
  });

  factory LecturerOverviewModel.fromJson(Map<String, dynamic> json) {
    return LecturerOverviewModel(
      lecturerId: json['lecturerId'] as int,
      lecturerName: json['lecturerName'] as String,
      departmentName: json['departmentName'] as String,
      academicRank: json['academicRank'] as String,
      degree: json['degree'] as String,
      totalCoursesThisSemester: json['totalCoursesThisSemester'] as int,
      totalSessionsThisSemester: json['totalSessionsThisSemester'] as int,
      completedSessions: json['completedSessions'] as int,
      upcomingSessions: json['upcomingSessions'] as int,
    );
  }
}

class TeachingStatsModel extends TeachingStats {
  const TeachingStatsModel({
    required super.totalCourses,
    required super.totalSessions,
    required super.completedSessions,
    required super.upcomingSessions,
    required super.canceledSessions,
    required super.completionRate,
    required super.monthlyTrend,
  });

  factory TeachingStatsModel.fromJson(Map<String, dynamic> json) {
    return TeachingStatsModel(
      totalCourses: json['totalCourses'] as int,
      totalSessions: json['totalSessions'] as int,
      completedSessions: json['completedSessions'] as int,
      upcomingSessions: json['upcomingSessions'] as int,
      canceledSessions: json['canceledSessions'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      monthlyTrend: (json['monthlyTrend'] as List)
          .map((e) => MonthlySessionCountModel.fromJson(e))
          .toList(),
    );
  }
}

class MonthlySessionCountModel extends MonthlySessionCount {
  const MonthlySessionCountModel({
    required super.month,
    required super.totalSessions,
    required super.completedSessions,
  });

  factory MonthlySessionCountModel.fromJson(Map<String, dynamic> json) {
    return MonthlySessionCountModel(
      month: json['month'] as String,
      totalSessions: json['totalSessions'] as int,
      completedSessions: json['completedSessions'] as int,
    );
  }
}

class CourseStatsModel extends CourseStats {
  const CourseStatsModel({
    required super.totalCourses,
    required super.courses,
  });

  factory CourseStatsModel.fromJson(Map<String, dynamic> json) {
    return CourseStatsModel(
      totalCourses: json['totalCourses'] as int,
      courses: (json['courses'] as List)
          .map((e) => CourseDetailModel.fromJson(e))
          .toList(),
    );
  }
}

class CourseDetailModel extends CourseDetail {
  const CourseDetailModel({
    required super.courseId,
    required super.courseName,
    required super.courseCode,
    required super.classCode,
    required super.credits,
    required super.totalSessions,
    required super.completedSessions,
    required super.completionRate,
    required super.sessionType,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      courseId: json['courseId'] as int,
      courseName: json['courseName'] as String,
      courseCode: json['courseCode'] as String,
      classCode: json['classCode'] as String,
      credits: json['credits'] as int,
      totalSessions: json['totalSessions'] as int,
      completedSessions: json['completedSessions'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      sessionType: json['sessionType'] as String,
    );
  }
}

class ScheduleStatsModel extends ScheduleStats {
  const ScheduleStatsModel({
    required super.totalScheduleDetails,
    required super.completedDetails,
    required super.upcomingDetails,
    required super.thisWeekSessions,
    required super.nextWeekSessions,
    required super.upcomingSessions,
  });

  factory ScheduleStatsModel.fromJson(Map<String, dynamic> json) {
    return ScheduleStatsModel(
      totalScheduleDetails: json['totalScheduleDetails'] as int,
      completedDetails: json['completedDetails'] as int,
      upcomingDetails: json['upcomingDetails'] as int,
      thisWeekSessions: json['thisWeekSessions'] as int,
      nextWeekSessions: json['nextWeekSessions'] as int,
      upcomingSessions: (json['upcomingSessions'] as List)
          .map((e) => UpcomingSessionModel.fromJson(e))
          .toList(),
    );
  }
}

class UpcomingSessionModel extends UpcomingSession {
  const UpcomingSessionModel({
    required super.scheduleDetailId,
    required super.courseName,
    required super.classCode,
    required super.sessionDate,
    required super.dayOfWeek,
    required super.timeRange,
    required super.roomName,
    required super.sessionType,
  });

  factory UpcomingSessionModel.fromJson(Map<String, dynamic> json) {
    return UpcomingSessionModel(
      scheduleDetailId: json['scheduleDetailId'] as int,
      courseName: json['courseName'] as String,
      classCode: json['classCode'] as String,
      sessionDate: json['sessionDate'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      timeRange: json['timeRange'] as String,
      roomName: json['roomName'] as String,
      sessionType: json['sessionType'] as String,
    );
  }
}

class AdjustmentRequestStatsModel extends AdjustmentRequestStats {
  const AdjustmentRequestStatsModel({
    required super.totalRequests,
    required super.pendingRequests,
    required super.approvedRequests,
    required super.rejectedRequests,
    required super.approvalRate,
    required super.recentRequests,
  });

  factory AdjustmentRequestStatsModel.fromJson(Map<String, dynamic> json) {
    return AdjustmentRequestStatsModel(
      totalRequests: json['totalRequests'] as int,
      pendingRequests: json['pendingRequests'] as int,
      approvedRequests: json['approvedRequests'] as int,
      rejectedRequests: json['rejectedRequests'] as int,
      approvalRate: (json['approvalRate'] as num).toDouble(),
      recentRequests: (json['recentRequests'] as List)
          .map((e) => RecentRequestModel.fromJson(e))
          .toList(),
    );
  }
}

class RecentRequestModel extends RecentRequest {
  const RecentRequestModel({
    required super.requestId,
    required super.courseName,
    required super.classCode,
    required super.reason,
    required super.status,
    required super.createdAt,
  });

  factory RecentRequestModel.fromJson(Map<String, dynamic> json) {
    return RecentRequestModel(
      requestId: json['requestId'] as int,
      courseName: json['courseName'] as String,
      classCode: json['classCode'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
