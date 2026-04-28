import '../entities/teacher_profile_entity.dart';
import '../repositories/teacher_profile_repository.dart';

class FetchTeacherProfileUseCase {
  final TeacherProfileRepository repository;

  FetchTeacherProfileUseCase({required this.repository});

  Future<TeacherProfileEntity> call() {
    return repository.getProfile();
  }
}
