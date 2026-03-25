// lib/core/notification/notification_helpers.dart

import 'package:flutter/foundation.dart' show kDebugMode;
// ✅ dùng model ở teacher
import '../../features/teacher/models/schedule_model.dart';
// Nếu bạn đặt tên file/model khác, dùng 1 trong 2 dòng ví dụ sau và bỏ dòng trên:
// import '../../features/teacher/models/teacher_schedule_model.dart' show ScheduleModel;
// import '../../features/teacher/models/teacher_schedule_model.dart' as tm; typedef ScheduleModel = tm.TeacherScheduleModel;

import '../../core/notification/notification_service.dart';

/// Parse "HH:mm - HH:mm" theo ngày d (local)
(DateTime start, DateTime end)? parseRangeForDate(String? timeRange, DateTime d) {
  if (timeRange == null) return null;
  final m = RegExp(r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})')
      .firstMatch(timeRange.trim());
  if (m == null) return null;

  final sh = int.parse(m.group(1)!);
  final sm = int.parse(m.group(2)!);
  final eh = int.parse(m.group(3)!);
  final em = int.parse(m.group(4)!);

  return (
  DateTime(d.year, d.month, d.day, sh, sm),
  DateTime(d.year, d.month, d.day, eh, em),
  );
}

/// Tạo ID thông báo ổn định theo scheduleId gốc
/// kind: 1 = -15' trước bắt đầu, 2 = -30' trước kết thúc, 8|9 = nhắc cửa sổ hoàn thành
int _notifId(int base, int kind) => base * 10 + kind;

/// ĐẶT 2 THÔNG BÁO CHO 1 BUỔI DẠY (teacher):
/// 1) 15 phút TRƯỚC GIỜ BẮT ĐẦU
/// 2) 30 phút TRƯỚC GIỜ KẾT THÚC
Future<void> scheduleTwoRemindersForItem(ScheduleModel item) async {
  final d = item.teachingDate;
  final parsed = parseRangeForDate(item.timeRange, d ?? DateTime.now());
  if (d == null || parsed == null) return;

  final (start, end) = parsed;
  final baseId = (item.id ?? item.hashCode).abs();

  // 1) Nhắc 15' trước bắt đầu
  await AppNotificationService.I.scheduleReminderBefore(
    scheduleId: _notifId(baseId, 1),
    title: 'Sắp vào dạy',
    body:
    'Bắt đầu lúc ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
    classStartLocal: start,
    before: const Duration(minutes: 15),
  );

  // 2) Nhắc 30' trước kết thúc
  await AppNotificationService.I.scheduleReminderBefore(
    scheduleId: _notifId(baseId, 2),
    title: 'Sắp kết thúc buổi dạy',
    body:
    'Kết thúc lúc ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
    classStartLocal: end,
    before: const Duration(minutes: 30),
  );

  if (kDebugMode) {
    // ignore: avoid_print
    print('[NOTI][TEACHER] ${item.subjectName} -> start=$start (-15m), end=$end (-30m)');
  }
}

/// (Tùy chọn) Nhắc khi sắp tới “cửa sổ hoàn thành buổi dạy”
Future<void> scheduleDoneWindowReminder(
    ScheduleModel item, {
      int windowBeforeMinutes = 15,       // khoảng trước giờ kết thúc được phép ấn Hoàn thành
      int notifyOffsetBeforeWindow = 0,   // nếu >0: nhắc sớm hơn X phút trước cửa sổ
    }) async {
  final d = item.teachingDate;
  final parsed = parseRangeForDate(item.timeRange, d ?? DateTime.now());
  if (d == null || parsed == null) return;

  final (_, end) = parsed;
  final windowStart = end.subtract(Duration(minutes: windowBeforeMinutes));
  final notifyAt = windowStart.subtract(Duration(minutes: notifyOffsetBeforeWindow));
  if (!notifyAt.isAfter(DateTime.now())) return;

  final baseId = (item.id ?? item.hashCode).abs();
  final kind = notifyOffsetBeforeWindow > 0 ? 9 : 8;

  await AppNotificationService.I.scheduleReminderBefore(
    scheduleId: _notifId(baseId, kind),
    title: notifyOffsetBeforeWindow == 0
        ? 'Đến giờ có thể đánh dấu hoàn thành buổi dạy'
        : 'Sắp tới thời điểm hoàn thành',
    body:
    'Thời điểm: ${windowStart.hour.toString().padLeft(2, '0')}:${windowStart.minute.toString().padLeft(2, '0')}',
    classStartLocal: windowStart,
    before: Duration(minutes: notifyOffsetBeforeWindow),
  );
}

/// HỦY 2 thông báo đã đặt cho 1 buổi dạy (teacher)
Future<void> cancelTwoRemindersForItem(ScheduleModel item) async {
  final baseId = (item.id ?? item.hashCode).abs();
  await AppNotificationService.I.cancel(_notifId(baseId, 1));
  await AppNotificationService.I.cancel(_notifId(baseId, 2));
}

/// HỦY các nhắc liên quan đến “cửa sổ hoàn thành buổi dạy”
Future<void> cancelDoneWindowReminders(ScheduleModel item) async {
  final baseId = (item.id ?? item.hashCode).abs();
  await AppNotificationService.I.cancel(_notifId(baseId, 8));
  await AppNotificationService.I.cancel(_notifId(baseId, 9));
}
