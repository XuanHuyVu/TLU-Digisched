import 'package:flutter/foundation.dart';
import '../../domain/entities/teacher_home_data_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/fetch_teacher_home_data_usecase.dart';
import '../../domain/usecases/mark_schedule_as_done_usecase.dart';
import '../../domain/usecases/request_class_cancel_usecase.dart';

class TeacherHomeNotifier extends ChangeNotifier {
  final FetchTeacherHomeDataUseCase fetchHomeDataUseCase;
  final MarkScheduleAsDoneUseCase markScheduleAsDoneUseCase;
  final RequestClassCancelUseCase requestClassCancelUseCase;

  TeacherHomeNotifier({
    required this.fetchHomeDataUseCase,
    required this.markScheduleAsDoneUseCase,
    required this.requestClassCancelUseCase,
  });

  bool _loading = false;
  String? _error;
  TeacherHomeDataEntity? _homeData;

  bool get loading => _loading;
  String? get error => _error;
  TeacherHomeDataEntity? get homeData => _homeData;

  int get periodsToday => _homeData?.periodsToday ?? 0;
  int get periodsThisWeek => _homeData?.periodsThisWeek ?? 0;
  int get percentCompleted => _homeData?.percentCompleted ?? 0;
  List<ScheduleEntity> get todaySchedules => _homeData?.todaySchedules ?? [];
  String get teacherName => _homeData?.teacher.name ?? 'Giảng viên';
  String get teacherFaculty => _homeData?.teacher.faculty ?? '';
  int get teacherId => _homeData?.teacher.id ?? 0;

  int get totalTodaySessions => todaySchedules.length;
  int get completedTodaySessions =>
      todaySchedules.where((s) => s.status == ScheduleStatus.done).length;
  int get percentTodayCompleted =>
      totalTodaySessions == 0
          ? 0
          : ((completedTodaySessions * 100) / totalTodaySessions).round();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _homeData = await fetchHomeDataUseCase();
    } catch (e) {
      _error = e.toString();
      _homeData = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markDone(ScheduleEntity item) async {
    if (item.id == 0) {
      throw Exception('Thiếu schedule detail id (id=0).');
    }

    final idx = todaySchedules.indexWhere((s) => s.id == item.id);
    ScheduleEntity? prev;

    if (idx != -1) {
      prev = todaySchedules[idx];
      final updated = prev.copyWith(status: ScheduleStatus.done);
      final clone = [...todaySchedules];
      clone[idx] = updated;
      _homeData = _homeData?.copyWith(
        todaySchedules: clone,
      );
      notifyListeners();
    }

    try {
      await markScheduleAsDoneUseCase(item.id);
    } catch (e) {
      if (idx != -1 && prev != null) {
        final clone = [...todaySchedules];
        clone[idx] = prev;
        _homeData = _homeData?.copyWith(
          todaySchedules: clone,
        );
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> requestCancel({
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
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

extension on TeacherHomeDataEntity {
  TeacherHomeDataEntity copyWith({List<ScheduleEntity>? todaySchedules}) {
    return TeacherHomeDataEntity(
      teacher: teacher,
      periodsToday: periodsToday,
      periodsThisWeek: periodsThisWeek,
      percentCompleted: percentCompleted,
      todaySchedules: todaySchedules ?? this.todaySchedules,
    );
  }
}
