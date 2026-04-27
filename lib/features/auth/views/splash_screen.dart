import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../student/views/screens/schedule_screen.dart';
import '../../lecturer/views/screens/teacher_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
  
class _SplashScreenState extends State<SplashScreen> {
  bool _didNavigate = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didNavigate || !mounted) return;

      final role = (auth.user?.role ?? '').trim().toUpperCase();

      Widget target;
      if (!auth.isLoggedIn) {
        target = const LoginScreen();
      } else if (role == 'LECTURER') {
        target = const TeacherHomeScreen();
      } else {
        target = const ScheduleScreen();
      }

      _didNavigate = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => target,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}