// import '../../domain/entities/teacher_stat_entity.dart';
// import '../../domain/repositories/teacher_stats_repository.dart';
// import '../datasources/teacher_stats_remote_datasource.dart';
// import '../models/teacher_stat_model.dart';
//
// class TeacherStatsRepositoryImpl implements TeacherStatsRepository {
//   final TeacherStatsRemoteDataSource remoteDataSource;
//
//   TeacherStatsRepositoryImpl({required this.remoteDataSource});
//
//   @override
//   Future<TeacherStatEntity> getStats() async {
//     try {
//       final data = await remoteDataSource.getStats();
//       return TeacherStatModel.fromJson(data);
//     } catch (e) {
//       throw Exception('Không thể tải thống kê: $e');
//     }
//   }
// }
