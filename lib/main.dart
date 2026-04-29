import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/features/auth/presentation/notifiers/auth_notifier.dart';
import 'features/auth/presentation/notifiers/auth_service_locator.dart';
import 'features/lecturer/presentation/views/screens/teacher_home_screen.dart';
import 'features/student/viewmodels/schedule_viewmodel.dart';
import 'features/auth/presentation/views/splash_screen.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/student/views/screens/schedule_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authNotifier = await AuthServiceLocator.setup(prefs);
  
  runApp(
    MyApp(authNotifier: authNotifier),
  );
}

class MyApp extends StatelessWidget {
  final AuthNotifier authNotifier;

  const MyApp({
    super.key,
    required this.authNotifier,
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
