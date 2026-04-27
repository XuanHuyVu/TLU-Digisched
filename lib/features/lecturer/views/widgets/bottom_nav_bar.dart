import 'package:flutter/material.dart';

class TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TeacherBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Lịch dạy'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Thống kê'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Hồ sơ'),
      ],
    );
  }
}
