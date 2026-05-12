import 'package:flutter/foundation.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/mark_schedule_as_done_usecase.dart';
import '../../domain/usecases/request_class_cancel_usecase.dart';
import '../../domain/usecases/fetch_all_schedules_usecase.dart';

class TeacherScheduleNotifier extends ChangeNotifier {
  final FetchAllSchedulesUseCase fetchAllSchedulesUseCase;
  final MarkScheduleAsDoneUseCase markScheduleAsDoneUseCase;
  final RequestClassCancelUseCase requestClassCancelUseCase;

  TeacherScheduleNotifier({
    required this.fetchAllSchedulesUseCase,
    required this.markScheduleAsDoneUseCase,
    required this.requestClassCancelUseCase,
  });

  bool _loading = false;
  String? _error;
  final List<ScheduleEntity> _schedules = [];
  
  Map<DateTime, List<ScheduleEntity>>? _cachedGroupedByDate;
  List<Map<String, dynamic>>? _cachedCourseStats;
  
  bool get loading => _loading;
  String? get error => _error;
  List<ScheduleEntity> get schedules => _schedules;
  
  Map<DateTime, List<ScheduleEntity>> get groupedByDate {
    if (_cachedGroupedByDate != null) return _cachedGroupedByDate!;
    _cachedGroupedByDate = {};
    for (final schedule in _schedules) {
      final scheduleDate = schedule.sessionDate;
      if (scheduleDate != null) {
        final dateOnly = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day);
        _cachedGroupedByDate!.putIfAbsent(dateOnly, () => []).add(schedule);
      }
    }
    return _cachedGroupedByDate!;
  }
  
  List<Map<String, dynamic>> get courseStats {
    if (_cachedCourseStats != null) return _cachedCourseStats!;
    final Map<String, List<ScheduleEntity>> courseGroups = {};
    for (final schedule in _schedules) {
      final key = '${schedule.classCode}_${schedule.subjectName}';
      courseGroups.putIfAbsent(key, () => []).add(schedule);
    }
    
    _cachedCourseStats = courseGroups.entries.map((entry) {
      final schedules = entry.value;
      final first = schedules.first;
      final totalSessions = schedules.length;
      final completedSessions = schedules.where((s) => s.status == ScheduleStatus.done).length;
      final progress = totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0.0;
      
      return {
        'subjectName': first.subjectName,
        'classCode': first.classCode,
        'sessionType': first.sessionType.displayName,
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'progress': progress,
        'schedules': schedules,
      };
    }).toList()
      ..sort((a, b) => (a['subjectName'] as String).compareTo(b['subjectName'] as String));
    
    return _cachedCourseStats!;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    _clearCache();
    notifyListeners();

    try {
      final allSchedules = await fetchAllSchedulesUseCase();
      _schedules.clear();
      _schedules.addAll(allSchedules);
      _error = null;
      _clearCache();
    } catch (e) {
      _error = e.toString();
      _schedules.clear();
      _clearCache();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markDone(ScheduleEntity schedule) async {
    try {
      if (schedule.id == 0) {
        throw Exception('Thiếu schedule id');
      }

      final idx = _schedules.indexWhere((s) => s.id == schedule.id);
      if (idx != -1) {
        final updated = schedule.copyWith(status: ScheduleStatus.done);
        _schedules[idx] = updated;
        _clearCache();
        notifyListeners();
      }

      await markScheduleAsDoneUseCase(schedule.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) async {
    try {
      await requestClassCancelUseCase(
        detailId: detailId,
        reason: reason,
        fileUrl: fileUrl,
      );
      return <String, dynamic>{'status': 'chưa duyệt'};
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  void _clearCache() {
    _cachedGroupedByDate = null;
    _cachedCourseStats = null;
  }
}
