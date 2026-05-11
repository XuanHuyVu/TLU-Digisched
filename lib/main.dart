import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/features/auth/presentation/notifiers/auth_notifier.dart';
import 'features/auth/presentation/notifiers/auth_service_locator.dart';
import 'features/lecturer/presentation/notifiers/teacher_service_locator.dart';
import 'features/lecturer/presentation/notifiers/teacher_schedule_notifier.dart';
import 'features/lecturer/presentation/notifiers/teacher_home_notifier.dart';
import 'features/lecturer/presentation/notifiers/teacher_notification_notifier.dart';
import 'features/lecturer/presentation/notifiers/teacher_profile_notifier.dart';
import 'features/lecturer/presentation/notifiers/teacher_stats_notifier.dart';
import 'features/lecturer/presentation/views/screens/teacher_home_screen.dart';
import 'features/student/viewmodels/schedule_viewmodel.dart';
import 'features/auth/presentation/views/splash_screen.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/student/views/screens/schedule_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authNotifier = await AuthServiceLocator.setup(prefs);
  final teacherNotifiers = await TeacherServiceLocator.setup(prefs);
  
  runApp(
    MyApp(
      authNotifier: authNotifier,
      teacherNotifiers: teacherNotifiers,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  final Map<String, dynamic> teacherNotifiers;

  const MyApp({
    super.key,
    required this.authNotifier,
    required this.teacherNotifiers,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _buildProviders(),
      child: MaterialApp(
        title: 'TLU Digisched',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/',
        routes: _buildRoutes(),
      ),
    );
  }

  List<ChangeNotifierProvider> _buildProviders() {
    return [
      ChangeNotifierProvider<AuthNotifier>.value(
        value: authNotifier,
      ),
      ChangeNotifierProvider(
        create: (_) => ScheduleViewModel(""),
      ),
      ChangeNotifierProvider<TeacherHomeNotifier>.value(
        value: teacherNotifiers['homeNotifier'] as TeacherHomeNotifier,
      ),
      ChangeNotifierProvider<TeacherScheduleNotifier>.value(
        value: teacherNotifiers['scheduleNotifier'] as TeacherScheduleNotifier,
      ),
      ChangeNotifierProvider<TeacherNotificationNotifier>.value(
        value: teacherNotifiers['notificationNotifier'] as TeacherNotificationNotifier,
      ),
      ChangeNotifierProvider<TeacherProfileNotifier>.value(
        value: teacherNotifiers['profileNotifier'] as TeacherProfileNotifier,
      ),
      ChangeNotifierProvider<TeacherStatsNotifier>.value(
        value: teacherNotifiers['statsNotifier'] as TeacherStatsNotifier,
      ),
    ];
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/schedule': (context) => const ScheduleScreen(),
      '/teacher_home': (context) => const TeacherHomeScreen(),
    };
  }
}
