import 'package:flutter/material.dart';
import '../../../domain/entities/schedule_entity.dart';
import 'package:intl/intl.dart';

const _brandBlue = Color(0xFF4A90E2);

class CourseDetailScreen extends StatelessWidget {
  final String courseName;
  final String classCode;
  final String sessionType;
  final List<ScheduleEntity> schedules;

  const CourseDetailScreen({
    super.key,
    required this.courseName,
    required this.classCode,
    required this.sessionType,
    required this.schedules,
  });

  ScheduleEntity _calculateEffectiveStatus(ScheduleEntity schedule) {
    // If already done or canceled, keep the status
    if (schedule.status == ScheduleStatus.done) return schedule;
    if (schedule.status == ScheduleStatus.canceled) return schedule;

    final now = DateTime.now();
    final d = schedule.sessionDate;
    
    // If no date, default to upcoming
    if (d == null) {
      return schedule.status == ScheduleStatus.unknown
          ? schedule.copyWith(status: ScheduleStatus.upcoming)
          : schedule;
    }

    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    
    // Future date -> upcoming
    if (thatDay.isAfter(today)) {
      return schedule.copyWith(status: ScheduleStatus.upcoming);
    }
    
    // Past date -> expired
    if (thatDay.isBefore(today)) {
      return schedule.copyWith(status: ScheduleStatus.expired);
    }
    
    // Same day - check time
    // For simplicity, if it's today and not done/canceled, mark as upcoming
    // (You can add more sophisticated time checking here if needed)
    return schedule.copyWith(status: ScheduleStatus.upcoming);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate effective status for each schedule
    final schedulesWithStatus = schedules.map((s) => _calculateEffectiveStatus(s)).toList();
    
    final totalSessions = schedulesWithStatus.length;
    final completedSessions = schedulesWithStatus.where((s) => s.status == ScheduleStatus.done).length;
    final upcomingSessions = schedulesWithStatus.where((s) => s.status == ScheduleStatus.upcoming).length;
    final canceledSessions = schedulesWithStatus.where((s) => s.status == ScheduleStatus.canceled).length;
    final progress = totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0.0;

    final sortedSchedules = List<ScheduleEntity>.from(schedulesWithStatus)
      ..sort((a, b) {
        if (a.sessionDate == null && b.sessionDate == null) return 0;
        if (a.sessionDate == null) return 1;
        if (b.sessionDate == null) return -1;
        return a.sessionDate!.compareTo(b.sessionDate!);
      });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'CHI TIẾT HỌC PHẦN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _brandBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.class_outlined,
                            label: classCode,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.menu_book_outlined,
                            label: sessionType,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Progress Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tiến độ giảng dạy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${progress.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _brandBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_brandBlue),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_outline,
                              label: 'Đã dạy',
                              value: '$completedSessions',
                              color: const Color(0xFF43A047),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.schedule_outlined,
                              label: 'Sắp tới',
                              value: '$upcomingSessions',
                              color: const Color(0xFFFB8C00),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.cancel_outlined,
                              label: 'Đã hủy',
                              value: '$canceledSessions',
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sessions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedSchedules.length,
              itemBuilder: (context, index) {
                final schedule = sortedSchedules[index];
                return _SessionCard(
                  schedule: schedule,
                  sessionNumber: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ScheduleEntity schedule;
  final int sessionNumber;

  const _SessionCard({
    required this.schedule,
    required this.sessionNumber,
  });

  Color _getStatusColor() {
    switch (schedule.status) {
      case ScheduleStatus.done:
        return const Color(0xFF43A047);
      case ScheduleStatus.canceled:
        return const Color(0xFFE53935);
      case ScheduleStatus.ongoing:
        return const Color(0xFF1E88E5);
      case ScheduleStatus.upcoming:
        return const Color(0xFFFB8C00);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (schedule.status) {
      case ScheduleStatus.done:
        return 'Đã hoàn thành';
      case ScheduleStatus.canceled:
        return 'Đã hủy';
      case ScheduleStatus.ongoing:
        return 'Đang diễn ra';
      case ScheduleStatus.upcoming:
        return 'Sắp tới';
      case ScheduleStatus.expired:
        return 'Đã quá hạn';
      default:
        return 'Không xác định';
    }
  }

  IconData _getStatusIcon() {
    switch (schedule.status) {
      case ScheduleStatus.done:
        return Icons.check_circle;
      case ScheduleStatus.canceled:
        return Icons.cancel;
      case ScheduleStatus.ongoing:
        return Icons.play_circle;
      case ScheduleStatus.upcoming:
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa xác định';
    try {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
    } catch (e) {
      final weekdays = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
      final weekday = weekdays[date.weekday % 7];
      return '$weekday, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isCompleted = schedule.status == ScheduleStatus.done;
    final isCanceled = schedule.status == ScheduleStatus.canceled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted || isCanceled
              ? statusColor.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _brandBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Buổi $sessionNumber',
                            style: TextStyle(
                              color: _brandBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(schedule.sessionDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          schedule.periodText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (schedule.timeRange.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          Text(
                            schedule.timeRange,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            schedule.roomName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                schedule.notes!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
