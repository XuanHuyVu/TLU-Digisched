import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route.dart';
import '../../../../core/enums/enum.dart';
import '../notifiers/auth_notifier.dart';
import '../../../student/viewmodels/schedule_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final authNotifier = context.read<AuthNotifier>();
    try {
      await authNotifier.loadUserFromStorage();
      if (!mounted) return;
      final isAuthenticated = authNotifier.isLoggedIn && authNotifier.isTokenValid;
      if (!isAuthenticated) {
        await authNotifier.logout();
        if (mounted) navigator.pushReplacementNamed(AppRoutes.login);
        return;
      }
      final userRole = UserRole.fromString(authNotifier.user?.role);
      switch (userRole) {
        case UserRole.student:
          final scheduleVM = context.read<ScheduleViewModel>();
          scheduleVM.updateToken(authNotifier.user?.token ?? "");
          await scheduleVM.loadSchedules();
          if (mounted) navigator.pushReplacementNamed(AppRoutes.schedule);
          return;
        case UserRole.lecturer:
          if (mounted) navigator.pushReplacementNamed(AppRoutes.teacherHome);
          return;
        default:
          await authNotifier.logout();
          if (mounted) navigator.pushReplacementNamed(AppRoutes.login);
          return;
      }
    } catch (_) {
      if (mounted) navigator.pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/tlu_pro_logo.png',
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school,
                      size: 50,
                      color: const Color(0xFF667EEA),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'TLU Digisched',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hệ thống quản lý thời khóa biểu',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF667EEA),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải...',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
