import 'dart:async';
import '../../../core/services/api_service.dart';
import '../models/student_schedule_model.dart';

class ScheduleService {
  ScheduleService(String token);

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _mondayOfWeek(DateTime d) {
    final weekday = d.weekday;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }

  DateTime _sundayOfWeek(DateTime d) {
    final monday = _mondayOfWeek(d);
    return monday.add(const Duration(days: 6));
  }

  Future<List<StudentScheduleModel>> fetchAllSchedules() async {
    dynamic res;
    try {
      res = await ApiService.getJson('/api/student/schedules');
    } on TimeoutException {
      throw Exception('Hệ thống bận. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Không thể tải lịch học: $e');
    }

    final List root = (res is List)
        ? res
        : (res is Map<String, dynamic>)
        ? (res['items'] ?? res['data'] ?? []) as List
        : const [];

    final List<StudentScheduleModel> all = root
        .whereType<Map<String, dynamic>>()
        .map((item) => StudentScheduleModel.fromJson(item))
        .toList();

    all.sort((a, b) {
      final ad = a.teachingDate ?? DateTime(2100);
      final bd = b.teachingDate ?? DateTime(2100);
      final c = ad.compareTo(bd);
      if (c != 0) return c;
      return a.periodStart.compareTo(b.periodStart);
    });

    return all;
  }

  Future<List<StudentScheduleModel>> fetchTodaySchedules() async {
    final all = await fetchAllSchedules();
    final now = DateTime.now();
    return all.where((s) => s.teachingDate != null && _sameDate(s.teachingDate!, now)).toList();
  }

  Future<List<StudentScheduleModel>> fetchThisWeekSchedules() async {
    final all = await fetchAllSchedules();
    final now = DateTime.now();
    final monday = _mondayOfWeek(now);
    final sunday = _sundayOfWeek(now);
    return all.where((s) {
      if (s.teachingDate == null) return false;
      final d = DateTime(s.teachingDate!.year, s.teachingDate!.month, s.teachingDate!.day);
      return !d.isBefore(monday) && !d.isAfter(sunday);
    }).toList();
  }
}