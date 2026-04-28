import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../../notifiers/teacher_schedule_notifier.dart';
import '../../notifiers/teacher_service_locator.dart';
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

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen>
    with TickerProviderStateMixin {
  late final Map<String, dynamic> _notifiers;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
  }

  Future<void> _initializeNotifiers() async {
    final prefs = await SharedPreferences.getInstance();
    _notifiers = await TeacherServiceLocator.setup(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.value(),
      builder: (context, snapshot) {
        return ChangeNotifierProvider.value(
          value:
              _notifiers['scheduleNotifier'] as TeacherScheduleNotifier? ??
              TeacherScheduleNotifier(
                markScheduleAsDoneUseCase: null as dynamic,
                requestClassCancelUseCase: null as dynamic,
              ),
          child: const _Body(),
        );
      },
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

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
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: _brandBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  tabs: const [Tab(text: 'Hôm nay'), Tab(text: 'Tuần này')],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [_DayTab(), _WeekTab()],
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
          final scheduleDate = s.teachingDate;
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

        if (todaySchedules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('Không có lịch cho ngày này.')),
          ),
      ],
    );
  }
}

class _WeekTab extends StatelessWidget {
  const _WeekTab();

  List<DateTime> _weekFromMonday(DateTime base) {
    final monday = base.subtract(Duration(days: base.weekday - 1));
    return List.generate(
      7,
      (i) => _dateOnly(DateTime(monday.year, monday.month, monday.day + i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<TeacherScheduleNotifier>();
    final today = DateTime.now();
    final weekDays = _weekFromMonday(today);
    final Map<DateTime, List<ScheduleEntity>> grouped = {};
    for (final schedule in notifier.schedules) {
      final scheduleDate = schedule.teachingDate;
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
          child: Text(
            'Tuần này không có lịch.',
            style: TextStyle(color: Colors.black.withAlpha(178)),
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
