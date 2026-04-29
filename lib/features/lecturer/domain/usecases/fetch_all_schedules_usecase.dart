import '../entities/schedule_entity.dart';
import '../repositories/teacher_repository.dart';

class FetchAllSchedulesUseCase {
  final TeacherRepository repository;

  FetchAllSchedulesUseCase({required this.repository});

  Future<List<ScheduleEntity>> call() {
    return repository.fetchAllSchedules();
  }
}
