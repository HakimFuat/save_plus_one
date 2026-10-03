import 'package:save_plus_one/features/auth/domain/repositories/auth_repository.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_email_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_exception.dart';

class SignInUseCase {
    final AuthRepository repository;

    SignInUseCase(this.repository);

    Future<String> execute({
        required String email,
        required String password,
    }) async {
        if (email.isEmpty) {
            throw const InvalidEmailException();
        }

        if (password.isEmpty) {
            throw const InvalidPasswordException();
        }
        return repository.signIn(email: email, password: password);
    }
}