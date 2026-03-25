import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/student/viewmodels/schedule_viewmodel.dart';
import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/student/views/screens/schedule_screen.dart';
import '../../../core/notification/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo notification service
  await AppNotificationService.I.init();

  // Khởi tạo AuthViewModel và load user từ storage
  final authVM = AuthViewModel();
  await authVM.loadUserFromStorage();

  // Khởi tạo ScheduleViewModel với token (giữ instance)
  final scheduleVM = ScheduleViewModel(authVM.user?.token ?? "");
  scheduleVM.loadSchedules(); // load lịch 1 lần ngay khi app start

  runApp(
    MultiProvider(
      providers: [
        // Giữ instance authVM
        ChangeNotifierProvider<AuthViewModel>.value(value: authVM),

        // Giữ instance scheduleVM để hot reload không reset
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
      title: 'TLU Schedule Pro',
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
