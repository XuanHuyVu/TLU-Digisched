import '../entities/teacher_home_data_entity.dart';
import '../repositories/teacher_repository.dart';

class FetchTeacherHomeDataUseCase {
  final TeacherRepository repository;

  FetchTeacherHomeDataUseCase({required this.repository});

  Future<TeacherHomeDataEntity> call() {
    return repository.fetchHomeData();
  }
}
