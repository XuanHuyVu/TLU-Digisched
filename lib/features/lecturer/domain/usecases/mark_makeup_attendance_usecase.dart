import '../repositories/teacher_repository.dart';

class MarkMakeupAttendanceUseCase {
  final TeacherRepository repository;

  MarkMakeupAttendanceUseCase({required this.repository});

  Future<void> call({
    required int scheduleDetailId,
    required String reason,
    String? fileUrl,
  }) {
    return repository.markMakeupAttendance(
      scheduleDetailId: scheduleDetailId,
      reason: reason,
      fileUrl: fileUrl,
    );
  }
}
