import '../../domain/entities/teacher_profile_entity.dart';
import '../../domain/repositories/teacher_profile_repository.dart';
import '../datasources/teacher_profile_remote_datasource.dart';
import '../models/teacher_profile_model.dart';

class TeacherProfileRepositoryImpl implements TeacherProfileRepository {
  final TeacherProfileRemoteDataSource remoteDataSource;

  TeacherProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TeacherProfileEntity> getProfile() async {
    try {
      final data = await remoteDataSource.getProfile();
      return TeacherProfileModel.fromJson(data);
    } catch (e) {
      throw Exception('Không thể tải profile: $e');
    }
  }
}
