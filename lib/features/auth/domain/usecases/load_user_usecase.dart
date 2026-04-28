import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoadUserUseCase {
  final AuthRepository repository;
  LoadUserUseCase(this.repository);
  Future<User?> call() {
    return repository.loadUserFromStorage();
  }
}
