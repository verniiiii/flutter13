import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity?> call(String email, String password, String confirmPassword) {
    return repository.register(email, password, confirmPassword);
  }
}

