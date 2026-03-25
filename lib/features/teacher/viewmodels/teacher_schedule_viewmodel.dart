import 'package:flutter/material.dart';

import '../models/schedule_model.dart';
import '../services/teacher_service.dart';
import '../services/teacher_schedule_service.dart';
import '../../auth/services/auth_service.dart';

// constants: tietToTime, format helpers...
import '../../../core/constants/constants.dart';
// local notifications
import '../../../core/notification/notification_service.dart';

class TeacherScheduleViewModel extends ChangeNotifier {
  final _service = TeacherService();

  final TeacherScheduleService _scheduleService = TeacherScheduleService(
    authHeaders: () async {
      final t = await AuthService.getToken();
      return t == null ? <String, String>{} : {'Authorization': 'Bearer $t'};
    },
  );

  bool loading = false;
  String? error;

  DateTime selectedDate = DateTime.now();
  List<ScheduleModel> all = const [];

  // ---------- Helpers "HH:mm" -> DateTime ----------
  DateTime? _dateWithHHmm(DateTime dateOnly, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(dateOnly.year, dateOnly.month, dateOnly.day, h, m);
  }

  /// Lấy "HH:mm - HH:mm" theo tiết bắt đầu/kết thúc
  (String, String)? _rangeHHmmByPeriod(int startPeriod, int endPeriod) {
    final s = tietToTime[startPeriod];
    final e = tietToTime[endPeriod];
    if (s == null || e == null) return null;
    final startHHmm = s.split('-').first.trim();
    final endHHmm = e.split('-').last.trim();
    return (startHHmm, endHHmm);
  }

  /// Thời điểm bắt đầu buổi học (local)
  DateTime? startDateTimeOf(ScheduleModel s) {
    final d = s.teachingDate;
    if (d == null) return null;
    final range = _rangeHHmmByPeriod(s.periodStart, s.periodEnd);
    if (range == null) return null;
    return _dateWithHHmm(d, range.$1);
  }

  /// Thời điểm kết thúc buổi học (local)
  DateTime? endDateTimeOf(ScheduleModel s) {
    final d = s.teachingDate;
    if (d == null) return null;
    final range = _rangeHHmmByPeriod(s.periodStart, s.periodEnd);
    if (range == null) return null;
    return _dateWithHHmm(d, range.$2);
  }

  // ---------- LOAD + ĐẶT NHẮC ----------
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      all = await _service.fetchAllSchedules();
      all = [...all]..sort((a, b) => a.periodStart.compareTo(b.periodStart));

      // Đặt nhắc: 15' trước bắt đầu & 30' trước kết thúc
      for (final s in all) {
        final int id = s.id; // giả định non-null
        if (id == 0) continue; // bỏ record lỗi nếu có

        final start = startDateTimeOf(s);
        if (start != null) {
          await AppNotificationService.I.scheduleReminderBefore(
            scheduleId: id,
            title: 'Sắp đến giờ dạy',
            body:
            '${s.subjectName ?? 'Môn học'} - Phòng ${s.roomName ?? ''} bắt đầu lúc ${_hhmm(start)}',
            classStartLocal: start,
            before: const Duration(minutes: 15),
          );
        }

        final end = endDateTimeOf(s);
        if (end != null) {
          await AppNotificationService.I.scheduleReminderBefore(
            scheduleId: id + 50000,
            title: 'Chuẩn bị hoàn thành',
            body:
            'Buổi ${s.subjectName ?? 'môn học'} sắp kết thúc, bạn có thể bấm Hoàn thành sau giờ học.',
            classStartLocal: end,
            before: const Duration(minutes: 30),
          );
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ---------- VIEW HELPERS ----------
  List<ScheduleModel> get daySchedules {
    final list = all.where((s) {
      final d = s.teachingDate;
      if (d == null) return false;
      return d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day;
    }).toList();
    list.sort((a, b) => a.periodStart.compareTo(b.periodStart));
    return list;
  }

  Map<DateTime, List<ScheduleModel>> get weekGrouped {
    if (all.isEmpty) return {};
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    bool inWeek(DateTime d) {
      final dd = DateTime(d.year, d.month, d.day);
      return !dd.isBefore(DateTime(monday.year, monday.month, monday.day)) &&
          !dd.isAfter(DateTime(sunday.year, sunday.month, sunday.day));
    }

    final map = <DateTime, List<ScheduleModel>>{};
    for (final s in all) {
      final d = s.teachingDate;
      if (d == null || !inWeek(d)) continue;
      final key = DateTime(d.year, d.month, d.day);
      (map[key] ??= []).add(s);
    }

    // sort list cho từng ngày (tránh dùng !)
    for (final list in map.values) {
      list.sort((a, b) => a.periodStart.compareTo(b.periodStart));
    }

    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  void pickDate(DateTime d) {
    selectedDate = d;
    notifyListeners();
  }

  void shiftWeek(int dir) {
    selectedDate = selectedDate.add(Duration(days: 7 * dir));
    notifyListeners();
  }

  void applyStatus(int id, ScheduleStatus status) {
    final i = all.indexWhere((e) => e.id == id);
    if (i != -1) {
      all[i] = all[i].copyWith(status: status);
      notifyListeners();
    }
  }

  // ---------- ĐÁNH DẤU HOÀN THÀNH ----------
  Future<void> markDone(ScheduleModel item) async {
    final idx = all.indexWhere((e) => e.id == item.id);
    if (idx == -1) return;

    final prev = all[idx];
    all[idx] = prev.copyWith(status: ScheduleStatus.done);
    notifyListeners();

    try {
      final res = await _scheduleService.markAsDone(item.id);
      final st = statusFromApi(res['status'] as String?);
      if (st != ScheduleStatus.unknown) {
        all[idx] = prev.copyWith(status: st);
        notifyListeners();
      }

      // Huỷ 2 nhắc của buổi này
      final int id = item.id; // non-null
      await AppNotificationService.I.cancel(id);
      await AppNotificationService.I.cancel(id + 50000);

      // Thông báo ngay “đã hoàn thành”
      final start = startDateTimeOf(item);
      await AppNotificationService.I.showNow(
        title: 'Đã hoàn thành buổi dạy',
        body:
        '${item.subjectName ?? 'Môn học'} (${_dateVN(start)} ${_hhmm(start)}) đã được đánh dấu hoàn thành.',
        id: id + 100000,
      );
    } catch (e) {
      all[idx] = prev;
      notifyListeners();
      rethrow;
    }
  }

  /// Gửi yêu cầu NGHỈ DẠY (cancel buổi học)
  Future<Map<String, dynamic>> requestCancel(
      ScheduleModel item, {
        required String reason,
        String? fileUrl,
      }) async {
    final int id = item.id; // non-null
    final res = await _scheduleService.requestClassCancel(
      detailId: id,
      reason: reason,
      fileUrl: fileUrl,
    );
    return res;
  }

  /// Huỷ tất cả thông báo cũ rồi load + đặt lại (tránh trùng khi refresh)
  Future<void> reload() async {
    try {
      await AppNotificationService.I.cancelAll();
    } catch (_) {}
    await load();
  }

  // ---------- Format helpers ----------
  String _hhmm(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dateVN(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
