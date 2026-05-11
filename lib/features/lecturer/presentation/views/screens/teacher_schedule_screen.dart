import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../../notifiers/teacher_schedule_notifier.dart';
import '../widgets/schedule_card.dart';

const _brandBlue = Color(0xFF4A90E2);
String _two(int n) => n.toString().padLeft(2, '0');
String _ddMMyyyy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String _weekdayFull(DateTime d) {
  const names = [
    'Chủ Nhật',
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
  ];
  return names[d.weekday % 7];
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load schedules when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherScheduleNotifier>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Body(tabController: _tabController);
  }
}

class _Body extends StatefulWidget {
  final TabController tabController;

  const _Body({required this.tabController});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    if (notifier.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (notifier.error != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi: ${notifier.error}', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          _ScheduleAppBar(
            title: 'LỊCH DẠY',
            onBack: () => Navigator.of(context).maybePop(),
            notifCount: 0,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: widget.tabController,
                  indicator: BoxDecoration(
                    color: _brandBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  tabs: const [
                    Tab(text: 'Hôm nay'),
                    Tab(text: 'Tuần này'),
                    Tab(text: 'Toàn kỳ'),
                    Tab(text: 'Học phần'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: const [_DayTab(), _WeekTab(), _SemesterTab(), _CoursesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final int notifCount;

  const _ScheduleAppBar({
    required this.title,
    this.onBack,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _brandBlue,
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                ),
              ),
              if (notifCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$notifCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayTab extends StatelessWidget {
  const _DayTab();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    final today = DateTime.now();
    final todaySchedules =
        notifier.schedules.where((s) {
          final scheduleDate = s.sessionDate;
          if (scheduleDate == null) return false;
          final sameDay =
              scheduleDate.year == today.year &&
              scheduleDate.month == today.month &&
              scheduleDate.day == today.day;
          return sameDay;
        }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _brandBlue.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: _brandBlue.withAlpha(45)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text(
                '${today.day}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_weekdayFull(today)}, ${today.day} tháng ${today.month} năm ${today.year}',
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...todaySchedules.map(
          (e) => ScheduleCard(
            item: e,
            onMarkDone: () => context.read<TeacherScheduleNotifier>().markDone(e),
            onRequestCancel:
                (reason, fileUrl) =>
                    context.read<TeacherScheduleNotifier>().requestCancel(
                      detailId: e.id,
                      reason: reason,
                      fileUrl: fileUrl,
                    ),
          ),
        ),
        if (todaySchedules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text('Không có lịch dạy hôm nay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Lịch có thể chưa được chính thức hóa',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WeekTab extends StatelessWidget {
  const _WeekTab();
  List<DateTime> _weekFromMonday(DateTime base) {
    final monday = base.subtract(Duration(days: base.weekday - 1));
    return List.generate(7, (i) => _dateOnly(DateTime(monday.year, monday.month, monday.day + i)));
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    final today = DateTime.now();
    final weekDays = _weekFromMonday(today);
    final Map<DateTime, List<ScheduleEntity>> grouped = {};
    for (final schedule in notifier.schedules) {
      final scheduleDate = schedule.sessionDate;
      if (scheduleDate != null) {
        final dateOnly = _dateOnly(scheduleDate);
        if (weekDays.contains(dateOnly)) {
          grouped.putIfAbsent(dateOnly, () => []).add(schedule);
        }
      }
    }
    final daysWithSchedules =
    weekDays.where((day) => (grouped[day] ?? []).isNotEmpty).toList();
    if (daysWithSchedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Tuần này không có lịch dạy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lịch có thể chưa được chính thức hóa',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children:
          daysWithSchedules.expand((date) {
            final list = grouped[date] ?? [];
            return [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${_weekdayFull(date)}, ${_ddMMyyyy(date)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _brandBlue,
                  ),
                ),
              ),
              ...list.map(
                (e) => ScheduleCard(
                  item: e,
                  onMarkDone:
                      () => context.read<TeacherScheduleNotifier>().markDone(e),
                  onRequestCancel:
                      (reason, fileUrl) =>
                          context.read<TeacherScheduleNotifier>().requestCancel(
                            detailId: e.id,
                            reason: reason,
                            fileUrl: fileUrl,
                          ),
                ),
              ),
            ];
          }).toList(),
    );
  }
}

class _SemesterTab extends StatelessWidget {
  const _SemesterTab();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    final Map<DateTime, List<ScheduleEntity>> grouped = {};
    for (final schedule in notifier.schedules) {
      final scheduleDate = schedule.sessionDate;
      if (scheduleDate != null) {
        final dateOnly = _dateOnly(scheduleDate);
        grouped.putIfAbsent(dateOnly, () => []).add(schedule);
      }
    }

    final sortedDates = grouped.keys.toList()..sort();
    
    if (sortedDates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có lịch dạy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lịch dạy chưa được chính thức hóa.\nVui lòng liên hệ phòng Đào tạo để biết thêm chi tiết.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: sortedDates.expand((date) {
        final list = grouped[date] ?? [];
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '${_weekdayFull(date)}, ${_ddMMyyyy(date)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _brandBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...list.map(
            (e) => ScheduleCard(
              item: e,
              onMarkDone:
                  () => context.read<TeacherScheduleNotifier>().markDone(e),
              onRequestCancel:
                  (reason, fileUrl) =>
                      context.read<TeacherScheduleNotifier>().requestCancel(
                        detailId: e.id,
                        reason: reason,
                        fileUrl: fileUrl,
                      ),
            ),
          ),
        ];
      }).toList(),
    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    
    // Group schedules by course (classCode + subjectName)
    final Map<String, List<ScheduleEntity>> courseGroups = {};
    for (final schedule in notifier.schedules) {
      final key = '${schedule.classCode}_${schedule.subjectName}';
      courseGroups.putIfAbsent(key, () => []).add(schedule);
    }

    if (courseGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có học phần',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có học phần nào được phân công.\nVui lòng liên hệ bộ môn để biết thêm chi tiết.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final courses = courseGroups.entries.map((entry) {
      final schedules = entry.value;
      final first = schedules.first;
      final totalSessions = schedules.length;
      final completedSessions = schedules.where((s) => s.status == ScheduleStatus.done).length;
      final progress = totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0.0;
      
      return {
        'subjectName': first.subjectName,
        'classCode': first.classCode,
        'sessionType': first.sessionType.displayName,
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'progress': progress,
        'schedules': schedules,
      };
    }).toList();

    // Sort by subject name
    courses.sort((a, b) => (a['subjectName'] as String).compareTo(b['subjectName'] as String));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _CourseCard(course: course);
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final subjectName = course['subjectName'] as String;
    final classCode = course['classCode'] as String;
    final sessionType = course['sessionType'] as String;
    final totalSessions = course['totalSessions'] as int;
    final completedSessions = course['completedSessions'] as int;
    final progress = course['progress'] as double;
    final schedules = course['schedules'] as List<ScheduleEntity>;
    final isCompleted = completedSessions == totalSessions;
    final statusColor = isCompleted ? const Color(0xFF43A047) : _brandBlue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Color(0xFF43A047)),
                                SizedBox(width: 4),
                                Text(
                                  'Hoàn thành',
                                  style: TextStyle(
                                    color: Color(0xFF43A047),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.class_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          classCode,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.menu_book_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          sessionType,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tiến độ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '$completedSessions/$totalSessions buổi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => CourseDetailScreen(
                    //           courseName: subjectName,
                    //           classCode: classCode,
                    //           sessionType: sessionType,
                    //           schedules: schedules,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 8),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: _brandBlue),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: const Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(Icons.visibility_outlined, size: 16, color: _brandBlue),
                    //         SizedBox(width: 6),
                    //         Text(
                    //           'Xem chi tiết',
                    //           style: TextStyle(
                    //             color: _brandBlue,
                    //             fontWeight: FontWeight.w700,
                    //             fontSize: 13,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
