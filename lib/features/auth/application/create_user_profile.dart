import 'package:save_plus_one/features/auth/domain/entities/user.dart';
import 'package:save_plus_one/features/auth/domain/repositories/user_repository.dart';

class CreateUserProfileUseCase {
  final UserRepository repository;

  CreateUserProfileUseCase(this.repository);

  Future<User> execute({
    required String id,
    required String email,
    required String displayName
  }) async {
    return repository.create(
      id: id,
      email: email,
      displayName: displayName,
    );
  }
}