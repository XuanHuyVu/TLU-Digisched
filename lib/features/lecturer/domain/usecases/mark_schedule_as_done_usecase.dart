import '../repositories/teacher_repository.dart';

class MarkScheduleAsDoneUseCase {
  final TeacherRepository repository;

  MarkScheduleAsDoneUseCase({required this.repository});

  Future<void> call(int scheduleDetailId) {
    return repository.markScheduleAsDone(scheduleDetailId);
  }
}
