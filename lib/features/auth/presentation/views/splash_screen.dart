import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    
    if (!mounted) {
      return;
    }
    
    try {
      final authNotifier = context.read<AuthNotifier>();
      await authNotifier.loadUserFromStorage();
      
      if (!mounted) {
        return;
      }
      
      if (authNotifier.isLoggedIn && authNotifier.isTokenValid) {
        final role = (authNotifier.user?.role ?? '').trim().toUpperCase();
        
        if (role == 'STUDENT') {
          final scheduleVM = context.read<ScheduleViewModel>();
          scheduleVM.updateToken(authNotifier.user?.token ?? "");
          scheduleVM.loadSchedules();
        }
        
        if (role == 'LECTURER') {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/teacher_home');
          }
        } else if (role == 'STUDENT') {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/schedule');
          }
        } else {
          await authNotifier.logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } else {
        await authNotifier.logout();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
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
            // Logo
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
            
            // App Name
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
            
            // Subtitle
            Text(
              'Hệ thống quản lý thời khóa biểu',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
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
            
            // Loading Text
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
