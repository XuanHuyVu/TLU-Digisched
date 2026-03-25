import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/teacher_schedule_viewmodel.dart';
import '../../models/schedule_model.dart';
import '../widgets/schedule_card.dart';

/// ---- Config & helpers -------------------------------------------------------

const _brandBlue = Color(0xFF4A90E2);

String _two(int n) => n.toString().padLeft(2, '0');
String _ddMMyyyy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

String _weekdayShort(DateTime d) {
  const names = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return names[d.weekday % 7];
}

String _weekdayFull(DateTime d) {
  const names = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
  return names[d.weekday % 7];
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// ---- Entry Screen -----------------------------------------------------------

class TeacherScheduleScreen extends StatelessWidget {
  const TeacherScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherScheduleViewModel()..load(),
      child: const _Body(),
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
    final vm = context.watch<TeacherScheduleViewModel>();

    if (vm.loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (vm.error != null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi: ${vm.error}', textAlign: TextAlign.center),
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

/// ---- AppBar component -------------------------------------------------------

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
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_rounded, color: Colors.white),
              ),
              if (notifCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$notifCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

/// ---- Tab: Ngày --------------------------------------------------------------

class _DayTab extends StatelessWidget {
  const _DayTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherScheduleViewModel>();
    final d = vm.selectedDate;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: _brandBlue.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: _brandBlue.withAlpha(45)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Text('${d.day}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('${_weekdayFull(d)}, ${d.day} tháng ${d.month} năm ${d.year}',
                  style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...vm.daySchedules.map(
              (e) => ScheduleCard(
            item: e,
            onMarkDone: () => context.read<TeacherScheduleViewModel>().markDone(e),
            onRequestCancel: (reason, fileUrl) =>
                context.read<TeacherScheduleViewModel>().requestCancel(
                  e,
                  reason: reason,
                  fileUrl: fileUrl,
                ),
          ),
        ),

        if (vm.daySchedules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('Không có lịch cho ngày này.')),
          ),
      ],
    );
  }
}

/// ---- Tab: Tuần --------------------------------------------------------------

class _WeekTab extends StatelessWidget {
  const _WeekTab();

  /// 7 ngày của tuần (T2..CN) chứa [base]
  List<DateTime> _weekFromMonday(DateTime base) {
    final monday = base.subtract(Duration(days: base.weekday - 1));
    return List.generate(7, (i) => _dateOnly(DateTime(monday.year, monday.month, monday.day + i)));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherScheduleViewModel>();
    final weekDays = _weekFromMonday(vm.selectedDate);

    // Chuẩn hóa key trong grouped
    final Map<DateTime, List<ScheduleModel>> grouped = {
      for (final e in vm.weekGrouped.entries) _dateOnly(e.key): e.value
    };

    return Column(
      children: [
        // Thanh chọn ngày (full tuần) – không cần cuộn, chia đều 7 cột
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => vm.shiftWeek(-1),
                icon: const Icon(Icons.chevron_left, size: 24),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final day = weekDays[i];
                    final isSelected = _dateOnly(day) == _dateOnly(vm.selectedDate);
                    final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
                    final hasSchedules = (grouped[day] ?? const <ScheduleModel>[]).isNotEmpty;

                    return Expanded(
                      child: _DayPill(
                        day: day,
                        isSelected: isSelected,
                        isToday: isToday,
                        hasSchedules: hasSchedules,
                        onTap: () => vm.pickDate(day),
                      ),
                    );
                  }),
                ),
              ),
              IconButton(
                onPressed: () => vm.shiftWeek(1),
                icon: const Icon(Icons.chevron_right, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Danh sách lịch học
        Expanded(
          child: _buildScheduleList(context, grouped, weekDays),
        ),
      ],
    );
  }

  Widget _buildScheduleList(
      BuildContext context,
      Map<DateTime, List<ScheduleModel>> grouped,
      List<DateTime> weekDays,
      ) {
    final vm = context.watch<TeacherScheduleViewModel>();
    final selectedDate = _dateOnly(vm.selectedDate);

    // Những ngày có lịch trong tuần
    final daysWithSchedules =
    weekDays.where((day) => (grouped[day] ?? const <ScheduleModel>[]).isNotEmpty).toList();

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

    // Sắp xếp: ngày đang chọn lên đầu nếu có, còn lại tăng dần
    final sortedDays = _sortDaysStartingFromSelected(daysWithSchedules, selectedDate);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: sortedDays.expand((date) {
        final list = grouped[date] ?? const <ScheduleModel>[];
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '${_weekdayFull(date)}, ${_ddMMyyyy(date)}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: _brandBlue),
            ),
          ),
          ...list.map(
                (e) => ScheduleCard(
              item: e,
              onMarkDone: () => context.read<TeacherScheduleViewModel>().markDone(e),
              onRequestCancel: (reason, fileUrl) =>
                  context.read<TeacherScheduleViewModel>().requestCancel(
                    e,
                    reason: reason,
                    fileUrl: fileUrl,
                  ),
            ),
          ),
        ];
      }).toList(),
    );
  }

  List<DateTime> _sortDaysStartingFromSelected(List<DateTime> days, DateTime selectedDate) {
    final sel = _dateOnly(selectedDate);
    if (days.contains(sel)) {
      final idx = days.indexOf(sel);
      return [sel, ...days.sublist(0, idx), ...days.sublist(idx + 1)];
    }
    final sorted = [...days]..sort();
    return sorted;
  }
}

/// Ô chọn ngày (1/7 cột)
class _DayPill extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasSchedules;
  final VoidCallback onTap;

  const _DayPill({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasSchedules,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _brandBlue
                : (isToday ? const Color(0x144A90E2) : Colors.transparent),
            border: Border.all(
              color: isSelected
                  ? _brandBlue
                  : (isToday ? _brandBlue : const Color(0x404A90E2)),
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayShort(day),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
              Text(
                '${day.day}',
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              Opacity(
                opacity: hasSchedules ? 1 : 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : _brandBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
