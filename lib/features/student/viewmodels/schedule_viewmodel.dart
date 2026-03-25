import 'package:flutter/material.dart';
import '../models/student_schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  late final ScheduleService _scheduleService;

  ScheduleViewModel(String token) {
    _scheduleService = ScheduleService(token);
  }

  List<StudentScheduleModel> _schedules = [];
  List<StudentScheduleModel> _filteredSchedules = [];
  bool _isLoading = false;
  String _errorMessage = '';

  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = false;

  List<StudentScheduleModel> get allSchedules => _schedules;
  List<StudentScheduleModel> get schedules => _filteredSchedules;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  bool get isWeekView => _isWeekView;

  void showToday() {
    _isWeekView = false;
    _selectedDate = DateTime.now();
    _filterSchedulesByDate();
    notifyListeners();
  }

  void showWeek() {
    _isWeekView = true;
    notifyListeners();
  }

  void toggleView() {
    _isWeekView = !_isWeekView;
    if (!_isWeekView) {
      _selectedDate = DateTime.now();
      _filterSchedulesByDate();
    }
    notifyListeners();
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _schedules = await _scheduleService.fetchAllSchedules();
      _filterSchedulesByDate();
    } catch (e) {
      debugPrint("Error loading schedules: $e");
      _errorMessage = e.toString();
      _schedules = [];
      _filteredSchedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _filterSchedulesByDate();
    notifyListeners();
  }

  Future<void> refreshSchedules() async {
    await loadSchedules();
  }

  void _filterSchedulesByDate() {
    _filteredSchedules = _schedules.where((schedule) {
      try {
        if (schedule.teachingDate == null) return false;

        final scheduleDate = schedule.teachingDate!;
        return scheduleDate.year == _selectedDate.year &&
            scheduleDate.month == _selectedDate.month &&
            scheduleDate.day == _selectedDate.day;
      } catch (e) {
        debugPrint("Invalid teachingDate: ${schedule.teachingDate}");
        return false;
      }
    }).toList();
  }

  void previousWeek() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _selectedDate = startOfWeek.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    _selectedDate = startOfWeek.add(const Duration(days: 7));
    notifyListeners();
  }

  List<StudentScheduleModel> getSchedulesForWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _schedules.where((s) {
      if (s.teachingDate == null) return false;
      final d = s.teachingDate!;
      return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
    }).toList();
  }

  List<DateTime> getWeekDates() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  String getVietnameseType(String? type) {
    switch (type) {
      case "LY_THUYET":
        return "Lý thuyết";
      case "THUC_HANH":
        return "Thực hành";
      default:
        return "Khác";
    }
  }

  String getVietnameseDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  String getVietnameseMonthName(int month) {
    switch (month) {
      case 1:
        return 'tháng 1';
      case 2:
        return 'tháng 2';
      case 3:
        return 'tháng 3';
      case 4:
        return 'tháng 4';
      case 5:
        return 'tháng 5';
      case 6:
        return 'tháng 6';
      case 7:
        return 'tháng 7';
      case 8:
        return 'tháng 8';
      case 9:
        return 'tháng 9';
      case 10:
        return 'tháng 10';
      case 11:
        return 'tháng 11';
      case 12:
        return 'tháng 12';
      default:
        return '';
    }
  }

  String getVietnameseWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 7:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}
