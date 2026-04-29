class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';

  static const String schedule = '/schedule';

  static const String teacherHome = '/teacher_home';
  static const String teacherSchedule = '/teacher_schedule';
  static const String teacherNotification = '/teacher_notification';

  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static const List<String> allRoutes = [
    splash,
    login,
    schedule,
    teacherHome,
    teacherSchedule,
    teacherNotification,
    home,
    profile,
    settings,
  ];

  static bool isValidRoute(String route) {
    return allRoutes.contains(route);
  }
}
