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
  bool get loading => _loading;
  String? get error => _error;
  List<ScheduleEntity> get schedules => _schedules;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final allSchedules = await fetchAllSchedulesUseCase();
      _schedules.clear();
      _schedules.addAll(allSchedules);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _schedules.clear();
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
}
