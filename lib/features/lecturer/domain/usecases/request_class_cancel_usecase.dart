import '../repositories/teacher_repository.dart';

class RequestClassCancelUseCase {
  final TeacherRepository repository;

  RequestClassCancelUseCase({required this.repository});

  Future<void> call({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) {
    return repository.requestClassCancel(
      detailId: detailId,
      reason: reason,
      fileUrl: fileUrl,
    );
  }
}
