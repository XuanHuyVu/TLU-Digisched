import 'package:flutter/material.dart';

class StatsPanel extends StatelessWidget {
  // Giữ nguyên API cũ
  final int periodsToday;
  final int periodsThisWeek;
  final int percentCompleted;

  // Bổ sung (tùy chọn): để hiện "đã hoàn thành / tổng"
  final int? completedToday;
  final int? totalToday;
  final int? completedWeek;
  final int? totalWeek;

  const StatsPanel({
    super.key,
    required this.periodsToday,
    required this.periodsThisWeek,
    required this.percentCompleted,
    this.completedToday,
    this.totalToday,
    this.completedWeek,
    this.totalWeek,
  });

  static const Color lightBlue = Color(0xFFE8F1FF);
  static const Color textBlue = Color(0xFF2F6BFF);

  int _percent(int? done, int? total) {
    if (done == null || total == null || total == 0) return 0;
    return ((done * 100) / total).round();
  }

  Widget _tile({
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: textBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textBlue),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayPct = _percent(completedToday, totalToday);
    final weekPct  = _percent(completedWeek, totalWeek);

    return Row(
      children: [
        // Ô 1: Hôm nay
        _tile(
          title: 'Tiết hôm nay',
          value: '$periodsToday',
          subtitle: (completedToday != null && totalToday != null)
              ? 'Đã xong $completedToday/$totalToday ($todayPct%)'
              : null,
        ),

        // Ô 2: Tuần này
        _tile(
          title: 'Tiết tuần này',
          value: '$periodsThisWeek',
          subtitle: (completedWeek != null && totalWeek != null)
              ? 'Tuần: $completedWeek/$totalWeek ($weekPct%)'
              : null,
        ),

        // Ô 3: Hoàn thành
        _tile(
          title: 'Hoàn thành',
          // Nếu có số liệu tuần X/Y thì ưu tiên hiển thị X/Y, nếu không dùng % cũ
          value: (completedWeek != null && totalWeek != null)
              ? '$completedWeek/$totalWeek'
              : '$percentCompleted%',
          subtitle: (completedWeek != null && totalWeek != null)
              ? 'Tỉ lệ tuần: $weekPct%'
              : null,
        ),
      ],
    );
  }
}
