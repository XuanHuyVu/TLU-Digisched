import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/notifiers/auth_notifier.dart';
import 'features/auth/presentation/notifiers/auth_service_locator.dart';
import 'features/student/viewmodels/schedule_viewmodel.dart';
import 'features/auth/presentation/views/splash_screen.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/student/views/screens/schedule_screen.dart';
import 'features/lecturer/views/screens/teacher_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final authNotifier = await AuthServiceLocator.setup(prefs);
  await authNotifier.loadUserFromStorage();

  final token = authNotifier.user?.token ?? "";
  final scheduleVM = ScheduleViewModel(token);

  if (authNotifier.isLoggedIn && token.isNotEmpty) {
    scheduleVM.loadSchedules();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: authNotifier),
        ChangeNotifierProvider<ScheduleViewModel>.value(value: scheduleVM),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Digisched',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/teacher_home': (context) => const TeacherHomeScreen(),
      },
    );
  }
}
