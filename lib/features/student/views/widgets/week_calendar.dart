import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import 'schedule_card.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({super.key});

  static const Color _brandBlue = Color(0xFF4A90E2);

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _weekdayShort(DateTime date) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleViewModel>(
      builder: (context, vm, child) {
        final weekDays = vm.getWeekDates();
        
        // ✅ Tối ưu: Sử dụng cached grouped data từ ViewModel
        final grouped = vm.getGroupedSchedules();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: vm.previousWeek,
                    icon: const Icon(Icons.chevron_left, size: 24),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekDays.map((day) {
                        final isToday =
                            _dateOnly(day) == _dateOnly(DateTime.now());
                        final hasSchedules =
                            (grouped[_dateOnly(day)] ?? []).isNotEmpty;

                        return Expanded(
                          child: RepaintBoundary(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0x144A90E2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isToday
                                      ? _brandBlue
                                      : const Color(0x404A90E2),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _weekdayShort(day),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Opacity(
                                    opacity: hasSchedules ? 1 : 0,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: _brandBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.nextWeek,
                    icon: const Icon(Icons.chevron_right, size: 24),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8)
                    .copyWith(bottom: 0),
                itemCount: weekDays.length,
                itemBuilder: (context, index) {
                  final date = weekDays[index];
                  final list = grouped[_dateOnly(date)] ?? [];
                  if (list.isEmpty) return const SizedBox.shrink();

                  return Column(
                    key: ValueKey('day_${date.millisecondsSinceEpoch}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${vm.getVietnameseWeekdayName(date.weekday)}, '
                              '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _brandBlue,
                          ),
                        ),
                      ),
                      ...list.map((e) => ScheduleCard(
                        key: ValueKey('schedule_${e.classSectionId}_${e.teachingDate?.millisecondsSinceEpoch}'),
                        schedule: e,
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
