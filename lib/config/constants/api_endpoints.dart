class ApiEndpoints {
  static const String baseUrl = 'http://172.30.208.1:8080/api/v1';
  static const String login = '$baseUrl/auth/login';
  static const String teacherNotifications = '$baseUrl/teacher/notifications';
  static const String teacherNotificationsRead = '$baseUrl/teacher/notifications/read/';
  static const String teacherProfile = '$baseUrl/teacher/profile';
  static const String teacherScheduleDetails = '$baseUrl/api/teacher/teaching-schedule-details/';
  static const String teacherClassCancel = '$baseUrl/teacher/class-cancel';
  static const String teacherStats = '$baseUrl/teacher/stats/me';
  static const String studentNotifications = '$baseUrl/student/notifications';
  static const String studentNotificationsRead = '$baseUrl/student/notifications/read/';
  static const String studentProfile = '$baseUrl/student/profile';
}