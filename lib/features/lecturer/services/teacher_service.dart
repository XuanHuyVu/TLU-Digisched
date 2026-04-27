import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api_service.dart';
import '../models/teacher_model.dart';
import '../models/schedule_model.dart';

class TeacherHomeData {
  final TeacherModel teacher;
  final int periodsToday;
  final int periodsThisWeek;
  final int percentCompleted;
  final List<ScheduleModel> todaySchedules;

  const TeacherHomeData({
    required this.teacher,
    required this.periodsToday,
    required this.periodsThisWeek,
    required this.percentCompleted,
    required this.todaySchedules,
  });
}

class TeacherService {
  Future<int?> _getTeacherId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('teacherId');
  }

  Future<String?> _getFullName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('fullName');
  }

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

  int _sumPeriods(List<ScheduleModel> xs) =>
      xs.fold(0, (acc, s) => acc + s.periodsCount);

  Future<TeacherHomeData> fetchHomeData() async {
    final teacherId = await _getTeacherId();
    if (teacherId == null) {
      throw Exception('Không tìm thấy teacherId. Hãy đăng nhập lại.');
    }

    final mockSchedules = [
      ScheduleModel(
        id: 1,
        teachingDate: DateTime.now(),
        periodStartRaw: '07:00',
        periodEndRaw: '07:50',
        periodStart: 1,
        periodEnd: 1,
        type: 'Lý thuyết',
        subjectName: 'Lập trình Dart',
        classCode: 'TIN1101',
        roomName: 'Phòng 101-A',
        chapter: 'Chương 1: Giới thiệu',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 2,
        teachingDate: DateTime.now(),
        periodStartRaw: '08:00',
        periodEndRaw: '09:40',
        periodStart: 2,
        periodEnd: 3,
        type: 'Thực hành',
        subjectName: 'Cơ sở dữ liệu',
        classCode: 'TIN1205',
        roomName: 'Phòng 205-B',
        chapter: 'Chương 2: SQL',
        status: ScheduleStatus.done,
      ),
      ScheduleModel(
        id: 3,
        teachingDate: DateTime.now().add(const Duration(days: 1)),
        periodStartRaw: '07:00',
        periodEndRaw: '07:50',
        periodStart: 1,
        periodEnd: 1,
        type: 'Lý thuyết',
        subjectName: 'Cấu trúc dữ liệu',
        classCode: 'TIN1103',
        roomName: 'Phòng 301-C',
        chapter: 'Chương 3: Stack & Queue',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 4,
        teachingDate: DateTime.now().add(const Duration(days: 1)),
        periodStartRaw: '09:45',
        periodEndRaw: '11:25',
        periodStart: 4,
        periodEnd: 5,
        type: 'Thực hành',
        subjectName: 'Lập trình Dart',
        classCode: 'TIN1101',
        roomName: 'Phòng 102-A',
        chapter: 'Chương 2: OOP',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 5,
        teachingDate: DateTime.now().add(const Duration(days: 2)),
        periodStartRaw: '13:45',
        periodEndRaw: '15:25',
        periodStart: 7,
        periodEnd: 8,
        type: 'Lý thuyết',
        subjectName: 'Phân tích thiết kế',
        classCode: 'TIN1301',
        roomName: 'Phòng 401-D',
        chapter: 'Chương 1: UML',
        status: ScheduleStatus.upcoming,
      ),
    ];

    dynamic res;
    try {
      res = await ApiService.getJson('/api/teacher/schedules/$teacherId');
    } on TimeoutException {
      throw Exception('Hệ thống bận. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Không thể tải lịch dạy: $e');
    }

    final List root = (res is List)
        ? res
        : (res is Map<String, dynamic>)
        ? (res['items'] ?? res['data'] ?? []) as List
        : const [];

    final List<ScheduleModel> all = [];
    for (final item in root.whereType<Map<String, dynamic>>()) {
      final section = (item['classSection'] ?? {}) as Map<String, dynamic>;
      final details = (item['details'] ?? []) as List;
      for (final d in details.whereType<Map<String, dynamic>>()) {
        all.add(ScheduleModel.fromSectionDetail(section: section, detail: d));
      }
    }

    final now = DateTime.now();
    final today = all.where((s) {
      if (s.teachingDate == null) return true;
      return _sameDate(s.teachingDate!, now);
    }).toList();

    final monday = _mondayOfWeek(now);
    final sunday = _sundayOfWeek(now);
    bool inWeek(DateTime d) => !d.isBefore(monday) && !d.isAfter(sunday);

    final thisWeek = all.where((s) {
      if (s.teachingDate == null) return true;
      final d = DateTime(s.teachingDate!.year, s.teachingDate!.month, s.teachingDate!.day);
      return inWeek(d);
    }).toList();

    final periodsToday = _sumPeriods(today);
    final periodsThisWeek = _sumPeriods(thisWeek);
    final doneCount = today.where((s) => s.status == ScheduleStatus.done).length;
    final percentCompleted = today.isEmpty ? 0 : ((doneCount / today.length) * 100).round();

    final name = await _getFullName() ?? 'Giảng viên';

    final teacher = TeacherModel(id: teacherId, name: name, faculty: 'Khoa Công nghệ Thông tin');

    return TeacherHomeData(
      teacher: teacher,
      periodsToday: periodsToday,
      periodsThisWeek: periodsThisWeek,
      percentCompleted: percentCompleted,
      todaySchedules: today,
    );
  }

  // ======= DÙNG CHO MÀN LỊCH DẠY (Ngày/Tuần) =======
  Future<List<ScheduleModel>> fetchAllSchedules() async {
    final teacherId = await _getTeacherId();
    if (teacherId == null) {
      throw Exception('Không tìm thấy teacherId. Hãy đăng nhập lại.');
    }

    // ============ MOCK DATA ============
    final mockSchedules = [
      ScheduleModel(
        id: 1,
        teachingDate: DateTime.now(),
        periodStartRaw: '07:00',
        periodEndRaw: '07:50',
        periodStart: 1,
        periodEnd: 1,
        type: 'Lý thuyết',
        subjectName: 'Lập trình Dart',
        classCode: 'TIN1101',
        roomName: 'Phòng 101-A',
        chapter: 'Chương 1: Giới thiệu',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 2,
        teachingDate: DateTime.now(),
        periodStartRaw: '08:00',
        periodEndRaw: '09:40',
        periodStart: 2,
        periodEnd: 3,
        type: 'Thực hành',
        subjectName: 'Cơ sở dữ liệu',
        classCode: 'TIN1205',
        roomName: 'Phòng 205-B',
        chapter: 'Chương 2: SQL',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 3,
        teachingDate: DateTime.now().add(const Duration(days: 1)),
        periodStartRaw: '07:00',
        periodEndRaw: '07:50',
        periodStart: 1,
        periodEnd: 1,
        type: 'Lý thuyết',
        subjectName: 'Cấu trúc dữ liệu',
        classCode: 'TIN1103',
        roomName: 'Phòng 301-C',
        chapter: 'Chương 3: Stack & Queue',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 4,
        teachingDate: DateTime.now().add(const Duration(days: 1)),
        periodStartRaw: '09:45',
        periodEndRaw: '11:25',
        periodStart: 4,
        periodEnd: 5,
        type: 'Thực hành',
        subjectName: 'Lập trình Dart',
        classCode: 'TIN1101',
        roomName: 'Phòng 102-A',
        chapter: 'Chương 2: OOP',
        status: ScheduleStatus.upcoming,
      ),
      ScheduleModel(
        id: 5,
        teachingDate: DateTime.now().subtract(const Duration(days: 1)),
        periodStartRaw: '13:45',
        periodEndRaw: '15:25',
        periodStart: 7,
        periodEnd: 8,
        type: 'Lý thuyết',
        subjectName: 'Phân tích thiết kế',
        classCode: 'TIN1301',
        roomName: 'Phòng 401-D',
        chapter: 'Chương 1: UML',
        status: ScheduleStatus.done,
      ),
    ];

    /* ============ API CALL (COMMENTED) ============
    dynamic res;
    try {
      res = await ApiService.getJson('/api/teacher/schedules/$teacherId');
    } on TimeoutException {
      throw Exception('Hệ thống bận. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Không thể tải lịch dạy: $e');
    }

    final List root = (res is List)
        ? res
        : (res is Map<String, dynamic>)
        ? (res['items'] ?? res['data'] ?? []) as List
        : const [];

    final List<ScheduleModel> all = [];
    for (final item in root.whereType<Map<String, dynamic>>()) {
      final section = (item['classSection'] ?? {}) as Map<String, dynamic>;
      final details = (item['details'] ?? []) as List;
      for (final d in details.whereType<Map<String, dynamic>>()) {
        all.add(ScheduleModel.fromSectionDetail(section: section, detail: d));
      }
    }
    ============================================ */

    final List<ScheduleModel> all = mockSchedules;

    all.sort((a, b) {
      final ad = a.teachingDate ?? DateTime(2100);
      final bd = b.teachingDate ?? DateTime(2100);
      final c = ad.compareTo(bd);
      if (c != 0) return c;
      return a.periodStart.compareTo(b.periodStart);
    });

    return all;
  }
}
