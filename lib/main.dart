import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/student/viewmodels/schedule_viewmodel.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/student/views/screens/schedule_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authVM = AuthViewModel();
  await authVM.loadUserFromStorage();
  final token = authVM.user?.token ?? "";
  final scheduleVM = ScheduleViewModel(token);
  
  if (authVM.isLoggedIn && token.isNotEmpty) {
    scheduleVM.loadSchedules();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authVM),
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/schedule': (context) => const ScheduleScreen(),
      },
    );
  }
}
