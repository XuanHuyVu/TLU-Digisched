import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';

/// Extension đặt tên cố định: ScheduleStatusStyleX
extension ScheduleStatusStyleX on ScheduleStatus {
  String get label {
    switch (this) {
      case ScheduleStatus.ongoing:  return 'ĐANG DIỄN RA';
      case ScheduleStatus.upcoming: return 'SẮP DIỄN RA';
      case ScheduleStatus.done:     return 'HOÀN THÀNH';
      case ScheduleStatus.expired:  return 'QUÁ GIỜ';
      case ScheduleStatus.canceled:
      case ScheduleStatus.unknown:
      default: return '';
    }
  }

  Color get color {
    switch (this) {
      case ScheduleStatus.ongoing:  return const Color(0xFF2F6BFF);
      case ScheduleStatus.upcoming: return const Color(0xFFFFA726);
      case ScheduleStatus.done:     return const Color(0xFF43A047);
      case ScheduleStatus.expired:  return const Color(0xFFE53935); // đỏ
      case ScheduleStatus.canceled:
      case ScheduleStatus.unknown:
      default: return Colors.grey;
    }
  }
}

class ScheduleStatusBadge extends StatelessWidget {
  final ScheduleStatus status;
  const ScheduleStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final label = ScheduleStatusStyleX(status).label;
    if (label.isEmpty) return const SizedBox.shrink();

    final color = ScheduleStatusStyleX(status).color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: .3,
        ),
      ),
    );
  }
}
