import '../entities/teacher_stat_entity.dart';

abstract class TeacherStatsRepository {
  Future<TeacherStatEntity> getStats();
}
