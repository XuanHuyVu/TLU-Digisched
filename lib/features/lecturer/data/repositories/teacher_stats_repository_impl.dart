import '../../domain/entities/teacher_stat_entity.dart';
import '../../domain/repositories/teacher_stats_repository.dart';
import '../datasources/teacher_stats_remote_datasource.dart';
import '../models/teacher_stat_model.dart';

class TeacherStatsRepositoryImpl implements TeacherStatsRepository {
  final TeacherStatsRemoteDataSource remoteDataSource;

  TeacherStatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TeacherStatEntity> getStats() async {
    try {
      final lecturerStats = await remoteDataSource.getStats();
      final totalSessions = lecturerStats.overview.totalSessionsThisSemester.toDouble();
      final completedSessions = lecturerStats.overview.completedSessions.toDouble();
      final upcomingSessions = lecturerStats.overview.upcomingSessions.toDouble();
      return TeacherStatModel(
        teacherId: lecturerStats.overview.lecturerId,
        teacherName: lecturerStats.overview.lecturerName,
        semesterId: 0,
        semesterName: 'Học kỳ hiện tại',
        taughtHours: completedSessions,
        notTaughtHours: 0.0,
        makeUpHours: 0.0,
        totalHours: totalSessions,
      );
    } catch (e) {
      throw Exception('Không thể tải thống kê: $e');
    }
  }
}
