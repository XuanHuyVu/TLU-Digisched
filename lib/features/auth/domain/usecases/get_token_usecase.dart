import '../repositories/auth_repository.dart';

class GetTokenUseCase {
  final AuthRepository repository;
  GetTokenUseCase(this.repository);
  Future<String?> call() {
    return repository.getToken();
  }
}
