import 'package:flutter/foundation.dart';
import '../../domain/entities/teacher_stat_entity.dart';
import '../../domain/usecases/fetch_teacher_stats_usecase.dart';

class TeacherStatsNotifier extends ChangeNotifier {
  final FetchTeacherStatsUseCase fetchStatsUseCase;

  TeacherStatsNotifier({required this.fetchStatsUseCase});

  bool _loading = false;
  String? _error;
  TeacherStatEntity? _stats;

  bool get loading => _loading;
  String? get error => _error;
  TeacherStatEntity? get stats => _stats;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await fetchStatsUseCase();
    } catch (e) {
      _error = e.toString();
      _stats = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
