import 'package:flutter/material.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../screens/class_cancel_screen.dart';
import '../screens/makeup_attendance_screen.dart';
import './schedule_status_badge.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleEntity item;
  final Future<void> Function()? onMarkDone;
  final Future<void> Function(String reason, String? fileUrl)? onMarkMakeupAttendance;
  final Future<Map<String, dynamic>> Function(String reason, String? fileUrl)? onRequestCancel;

  const ScheduleCard({
    super.key,
    required this.item,
    this.onMarkDone,
    this.onMarkMakeupAttendance,
    this.onRequestCancel,
  });
  static final _timeRangeRegex = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})');
  Future<void> _showCustomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Color titleColor,
    IconData? icon,
    Color? iconColor,
  }) async {
    await showDialog<void>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Icon(icon, size: 48, color: iconColor ?? titleColor),
                  if (icon != null) const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: titleColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    Color color = const Color(0xFF2E7D32),
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline, size: 48, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black26),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
    return ok == true;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  (DateTime, DateTime)? _parseRangeForDate(DateTime baseDate) {
    final tr = (item.timeRange).trim();
    final m = _timeRangeRegex.firstMatch(tr);
    if (m == null) return null;
    final sh = int.parse(m.group(1)!);
    final sm = int.parse(m.group(2)!);
    final eh = int.parse(m.group(3)!);
    final em = int.parse(m.group(4)!);
    final start = DateTime(baseDate.year, baseDate.month, baseDate.day, sh, sm);
    final end = DateTime(baseDate.year, baseDate.month, baseDate.day, eh, em);
    return (start, end);
  }

  ScheduleStatus get effectiveStatus {
    if (item.status == ScheduleStatus.done) return ScheduleStatus.done;
    if (item.status == ScheduleStatus.canceled) return ScheduleStatus.canceled;

    final now = DateTime.now();
    final d = item.sessionDate;
    if (d == null) {
      return item.status == ScheduleStatus.unknown
          ? ScheduleStatus.upcoming
          : item.status;
    }

    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    if (thatDay.isAfter(today)) return ScheduleStatus.upcoming;
    if (thatDay.isBefore(today)) return ScheduleStatus.expired;
    final range = _parseRangeForDate(today);
    if (range == null) {
      return item.status == ScheduleStatus.unknown
          ? ScheduleStatus.upcoming
          : item.status;
    }
    final (start, end) = range;
    if (now.isBefore(start)) return ScheduleStatus.upcoming;
    if (now.isAfter(end)) return ScheduleStatus.expired;
    return ScheduleStatus.ongoing;
  }

  /// Kiểm tra xem có thể đánh dấu hoàn thành không
  /// Logic mới: Cho phép đánh dấu khi buổi học đã bắt đầu (ongoing hoặc expired)
  bool _canMarkComplete() {
    // Không thể đánh dấu nếu đã hoàn thành hoặc đã hủy
    if (item.isCompleted) return false;
    if (item.status == ScheduleStatus.done) return false;
    if (item.status == ScheduleStatus.canceled) return false;
    
    final now = DateTime.now();
    final d = item.sessionDate;
    if (d == null) return false;
    
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    
    // Không thể đánh dấu nếu chưa đến ngày
    if (thatDay.isAfter(today)) return false;
    
    // Nếu là ngày hôm nay, kiểm tra xem đã bắt đầu chưa
    if (_isSameDay(today, thatDay)) {
      final range = _parseRangeForDate(today);
      if (range == null) return false;
      final (start, _) = range;
      // Chỉ cho phép đánh dấu khi buổi học đã bắt đầu
      return now.isAfter(start) || now.isAtSameMomentAs(start);
    }
    
    // Nếu là ngày trong quá khứ, luôn cho phép đánh dấu
    return true;
  }

  /// Kiểm tra xem có phải là expired (quá hạn) không
  bool _isExpired() {
    final now = DateTime.now();
    final d = item.sessionDate;
    if (d == null) return false;
    
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    
    // Nếu là ngày trong quá khứ
    if (thatDay.isBefore(today)) return true;
    
    // Nếu là hôm nay, kiểm tra xem đã kết thúc chưa
    if (_isSameDay(today, thatDay)) {
      final range = _parseRangeForDate(today);
      if (range == null) return false;
      final (_, end) = range;
      return now.isAfter(end);
    }
    
    return false;
  }

  String _formatHm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  (bool, String?, DateTime?, DateTime?) _canCompleteNow() {
    final now = DateTime.now();
    final d = item.sessionDate;
    if (d == null) return (false, 'Không xác định ngày học.', null, null);
    
    final range = _parseRangeForDate(DateTime(d.year, d.month, d.day));
    if (range == null) {
      return (false, 'Không xác định được khung giờ của buổi học.', null, null);
    }
    
    final (start, _) = range;
    
    // Kiểm tra xem buổi học đã bắt đầu chưa
    if (now.isBefore(start)) {
      return (
        false,
        'Buổi học chưa bắt đầu. Vui lòng đợi đến ${_formatHm(start)}.',
        start,
        null,
      );
    }
    
    // Đã bắt đầu hoặc đã kết thúc - đều cho phép đánh dấu
    return (true, null, start, null);
  }

  Widget _chipButton(String text, Color fg, Color bg, VoidCallback? onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      );

  bool _canRequestCancel() {
    if (item.status == ScheduleStatus.done) return false;
    if (item.status == ScheduleStatus.canceled) return false;
    if (effectiveStatus == ScheduleStatus.expired) return false;
    final now = DateTime.now();
    final d = item.sessionDate;
    if (d == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    if (thatDay.isAfter(today)) return true;
    if (thatDay.isBefore(today)) return false;
    final range = _parseRangeForDate(today);
    if (range == null) return false;
    final (start, _) = range;
    return now.isBefore(start);
  }

  @override
  Widget build(BuildContext context) {
    final header =
        item.timeRange.isNotEmpty
            ? 'Tiết ${item.startPeriod} → ${item.endPeriod} (${item.timeRange})'
            : item.periodText;
    
    // Xác định các điều kiện hiển thị nút
    final canMarkComplete = _canMarkComplete();
    final isExpired = _isExpired();
    final showCancelButton = _canRequestCancel();
    
    // Xác định label và màu cho nút hoàn thành
    final completeButtonLabel = isExpired ? 'Điểm danh bù' : 'Hoàn thành';
    final completeButtonFg = isExpired ? const Color(0xFF6A1B9A) : const Color(0xFF2E7D32);
    final completeButtonBg = isExpired ? const Color(0xFFF3E5F5) : const Color(0xFFE2F3E6);
    
    final statusColor = ScheduleStatusStyleX(effectiveStatus).color;
    final statusLabel = ScheduleStatusStyleX(effectiveStatus).label;
    
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          header,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (statusLabel.isNotEmpty)
                          ScheduleStatusBadge(status: effectiveStatus),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.subjectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(item.roomName),
                        const SizedBox(width: 14),
                        const Icon(Icons.menu_book_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(item.sessionType.displayName),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (canMarkComplete || showCancelButton)
                      Row(
                        children: [
                          if (canMarkComplete)
                            _chipButton(
                              completeButtonLabel,
                              completeButtonFg,
                              completeButtonBg,
                              () async {
                                // Nếu là điểm danh bù, mở màn hình nhập lý do
                                if (isExpired) {
                                  if (onMarkMakeupAttendance == null) return;
                                  
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MakeupAttendanceScreen(
                                        item: item,
                                        onSubmit: onMarkMakeupAttendance!,
                                      ),
                                    ),
                                  );
                                  
                                  if (!context.mounted) return;
                                  if (result == true) {
                                    await _showCustomDialog(
                                      context,
                                      title: 'Thành công',
                                      message: 'Đã đánh dấu điểm danh bù thành công',
                                      titleColor: const Color(0xFF6A1B9A),
                                      icon: Icons.check_circle,
                                      iconColor: const Color(0xFF6A1B9A),
                                    );
                                  }
                                  return;
                                }
                                
                                // Logic hoàn thành bình thường
                                final confirm = await _showConfirmDialog(
                                  context,
                                  title: 'Xác nhận hoàn thành?',
                                  message: 'Bạn có muốn đánh dấu buổi học này là HOÀN THÀNH không?',
                                  color: const Color(0xFF2E7D32),
                                );
                                if (!confirm) return;
                                if (!context.mounted) return;
                                
                                final (ok, reason, from, _) = _canCompleteNow();
                                if (!ok) {
                                  if (!context.mounted) return;
                                  var msg = reason ?? 'Không thể cập nhật.';
                                  if (from != null) {
                                    msg += '\nBuổi học bắt đầu lúc: ${_formatHm(from)}';
                                  }
                                  await _showCustomDialog(
                                    context,
                                    title: 'Chưa thể đánh dấu',
                                    message: msg,
                                    titleColor: const Color(0xFFFFA726),
                                    icon: Icons.access_time,
                                    iconColor: const Color(0xFFFFA726),
                                  );
                                  return;
                                }
                                
                                if (onMarkDone == null) return;
                                try {
                                  await onMarkDone!();
                                  if (!context.mounted) return;
                                  await _showCustomDialog(
                                    context,
                                    title: 'Thành công',
                                    message: 'Đã cập nhật: Hoàn thành',
                                    titleColor: const Color(0xFF43A047),
                                    icon: Icons.check_circle,
                                    iconColor: const Color(0xFF43A047),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  await _showCustomDialog(
                                    context,
                                    title: 'Lỗi',
                                    message: e.toString(),
                                    titleColor: const Color(0xFFE53935),
                                    icon: Icons.error_outline,
                                    iconColor: const Color(0xFFE53935),
                                  );
                                }
                              },
                            ),
                          if (canMarkComplete && showCancelButton)
                            const SizedBox(width: 10),
                          if (showCancelButton)
                            _chipButton(
                              'Nghỉ dạy',
                              const Color(0xFFF29900),
                              const Color(0xFFFFF1D9),
                              () async {
                                final cancelHandler = onRequestCancel;
                                if (cancelHandler == null) return;
                                final result = await Navigator.push<Map<String, dynamic>?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClassCancelScreen(
                                      item: item,
                                      onSubmit: cancelHandler,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (result != null) {
                                  await _showCustomDialog(
                                    context,
                                    title: 'Đã gửi yêu cầu',
                                    message: 'Trạng thái: ${(result['status'] ?? 'chưa duyệt').toString()}',
                                    titleColor: const Color(0xFFF29900),
                                    icon: Icons.send,
                                    iconColor: const Color(0xFFF29900),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
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
