import '../entities/teacher_stat_entity.dart';
import '../repositories/teacher_stats_repository.dart';

class FetchTeacherStatsUseCase {
  final TeacherStatsRepository repository;

  FetchTeacherStatsUseCase({required this.repository});

  Future<TeacherStatEntity> call() {
    return repository.getStats();
  }
}
