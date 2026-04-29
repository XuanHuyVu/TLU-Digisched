import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/shared/extensions/date_extensions.dart';
import '../../notifiers/teacher_home_notifier.dart';
import '../../notifiers/teacher_notification_notifier.dart';
import '../../notifiers/teacher_schedule_notifier.dart';
import '../../notifiers/teacher_service_locator.dart';
import 'teacher_profile_screen.dart';
import 'teacher_notification_screen.dart';
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
  late Future<Map<String, dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeNotifiers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Lỗi: ${snapshot.error}")),
          );
        }
        
        final notifiers = snapshot.data;
        if (notifiers == null) {
          return const Scaffold(
            body: Center(child: Text("Không thể khởi tạo dữ liệu")),
          );
        }
        
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: notifiers['homeNotifier'] as TeacherHomeNotifier,
            ),
            ChangeNotifierProvider.value(
              value: notifiers['scheduleNotifier'] as TeacherScheduleNotifier,
            ),
            ChangeNotifierProvider.value(
              value:
                  notifiers['notificationNotifier']
                      as TeacherNotificationNotifier,
            ),
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
      },
    );
  }

  Future<Map<String, dynamic>> _initializeNotifiers() async {
    final prefs = await SharedPreferences.getInstance();
    return await TeacherServiceLocator.setup(prefs);
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherHomeNotifier>();

    if (notifier.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (notifier.error != null) {
      return SafeArea(child: Center(child: Text('Lỗi: ${notifier.error}')));
    }

    final todayStr = DateTime.now().toDdMMyyyy();
    final displayName =
        notifier.teacherName.isNotEmpty ? notifier.teacherName : 'Giảng viên';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _TopBar(name: displayName),
          const SizedBox(height: 12),

          StatsPanel(
            periodsToday: notifier.periodsToday,
            periodsThisWeek: notifier.periodsThisWeek,
            percentCompleted: notifier.percentCompleted,
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Lịch dạy hôm nay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                ],
              ),
            ],
          ),

          ...notifier.todaySchedules.map(
            (e) => ScheduleCard(
              item: e,
              onMarkDone: () async {
                await notifier.markDone(e);
              },
            ),
          ),

          if (notifier.todaySchedules.isEmpty)
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
  const _TopBar({required this.name});

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\\s+'));
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherNotificationNotifier>();
    final unread = notifier.unreadCount;
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
                icon: const Icon(Icons.notifications_rounded, size: 30),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
