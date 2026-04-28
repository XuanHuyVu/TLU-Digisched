import '../entities/teacher_profile_entity.dart';

abstract class TeacherProfileRepository {
  Future<TeacherProfileEntity> getProfile();
}
