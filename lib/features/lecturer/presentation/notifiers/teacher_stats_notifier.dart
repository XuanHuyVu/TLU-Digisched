import 'package:flutter/foundation.dart';
import '../../domain/entities/teacher_stat_entity.dart';
import '../../domain/usecases/fetch_teacher_stats_usecase.dart';

class TeacherStatsNotifier extends ChangeNotifier {
  final FetchTeacherStatsUseCase fetchStatsUseCase;

  TeacherStatsNotifier({required this.fetchStatsUseCase});

  bool _loading = false;
  String? _error;
  TeacherStatEntity? _stats;
  double? _cachedCompletionRate;
  bool get loading => _loading;
  String? get error => _error;
  TeacherStatEntity? get stats => _stats;
  
  double get completionRate {
    if (_cachedCompletionRate != null) return _cachedCompletionRate!;
    
    if (_stats == null || _stats!.totalHours <= 0) {
      _cachedCompletionRate = 0.0;
    } else {
      _cachedCompletionRate = 
          ((_stats!.taughtHours + _stats!.makeUpHours) / _stats!.totalHours * 100);
    }
    return _cachedCompletionRate!;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    _cachedCompletionRate = null;
    notifyListeners();

    try {
      _stats = await fetchStatsUseCase();
      _cachedCompletionRate = null; // Trigger recalculation
    } catch (e) {
      _error = e.toString();
      _stats = null;
      _cachedCompletionRate = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
