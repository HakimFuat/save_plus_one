import 'package:save_plus_one/features/auth/domain/repositories/auth_repository.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_email_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_confirmation_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/password_mismatch_exception.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<String> execute({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.isEmpty) {
      throw const InvalidEmailException();
    }
    if (password.isEmpty) {
      throw const InvalidPasswordException();
    }
    if (confirmPassword.isEmpty) {
        throw const InvalidPasswordConfirmationException();
    }
    if (password != confirmPassword) {
        throw const PasswordMismatchException();
    }

    return repository.signUp(
      email: email,
      password: password,
    );
  }
}