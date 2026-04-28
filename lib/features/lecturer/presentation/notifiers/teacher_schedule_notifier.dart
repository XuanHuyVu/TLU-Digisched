import 'package:flutter/foundation.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/mark_schedule_as_done_usecase.dart';
import '../../domain/usecases/request_class_cancel_usecase.dart';

class TeacherScheduleNotifier extends ChangeNotifier {
  final MarkScheduleAsDoneUseCase markScheduleAsDoneUseCase;
  final RequestClassCancelUseCase requestClassCancelUseCase;

  TeacherScheduleNotifier({
    required this.markScheduleAsDoneUseCase,
    required this.requestClassCancelUseCase,
  });

  final bool _loading = false;
  String? _error;
  final List<ScheduleEntity> _schedules = [];
  bool get loading => _loading;
  String? get error => _error;
  List<ScheduleEntity> get schedules => _schedules;

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
