import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'teacher_profile_screen.dart';
import 'teacher_notification_screen.dart';
import '../../viewmodels/teacher_home_viewmodel.dart';
import '../../viewmodels/teacher_schedule_viewmodel.dart';
import '../../models/schedule_model.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/schedule_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/stats_panel.dart';
import 'teacher_schedule_screen.dart';
import 'teacher_stat_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _index = 0;

  // Khởi tạo VM 1 lần, tránh tạo lại khi setState đổi tab
  late final TeacherHomeViewModel _homeVM;
  late final TeacherScheduleViewModel _scheduleVM;

  @override
  void initState() {
    super.initState();
    _homeVM = TeacherHomeViewModel()..load();
    _scheduleVM = TeacherScheduleViewModel()..load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _homeVM),
        ChangeNotifierProvider.value(value: _scheduleVM),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            _HomeTab(onSeeAll: () => setState(() => _index = 1)),
            const TeacherScheduleScreen(),
            const _StatsTab(),
            const _ProfileTab(),
          ],
        ),
        bottomNavigationBar: TeacherBottomNavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

/// Trang chủ (dashboard)
class _HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherHomeViewModel>();

    if (vm.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (vm.error != null) {
      return SafeArea(child: Center(child: Text('Lỗi: ${vm.error}')));
    }

    final todayStr = formatDdMMyyyy(DateTime.now());
    final displayName = vm.teacherName.isNotEmpty ? vm.teacherName : 'Giảng viên';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _TopBar(name: displayName),
          const SizedBox(height: 12),

          StatsPanel(
            periodsToday: vm.periodsToday,
            periodsThisWeek: vm.periodsThisWeek,
            percentCompleted: vm.percentCompleted,
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('Lịch dạy hôm nay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    todayStr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ]),
            ],
          ),

          ...vm.todaySchedules.map(
                (e) => ScheduleCard(
              item: e,
              onMarkDone: () async {
                final schedVM = context.read<TeacherScheduleViewModel>();
                await vm.markDone(e);
                schedVM.applyStatus(e.id, ScheduleStatus.done);
              },
            ),
          ),

          if (vm.todaySchedules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Hôm nay không có lịch dạy.'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String name;
  const _TopBar({super.key, required this.name});

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\\s+'));
    if (parts.length >= 2) return (parts.first[0] + parts.last[0]).toUpperCase();
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherHomeViewModel>();
    final unread = vm.unreadCount; // Thuộc tính thêm trong ViewModel

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Image.asset('assets/images/LOGO_THUYLOI.png', height: 28),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeacherNotificationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_rounded, size: 30), // chuông to hơn
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2), // nhỏ hơn
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9, // chữ nhỏ hơn
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2F6BFF),
            child: Text(
              _getInitials(name),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();
  @override
  Widget build(BuildContext context) => const TeacherStatScreen();
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => const TeacherProfileScreen();
}
