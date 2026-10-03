import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/application/sign_up.dart';
import 'fakes/fake_auth_repository.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_email_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_confirmation_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/password_mismatch_exception.dart';

void main() {
  test('should return user id when sign up credentials are valid', () async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignUpUseCase(repository);

    // When
    final userId = await useCase.execute(
      email: 'hakim@example.com',
      password: 'password123',
      confirmPassword: 'password123',
    );

    // Then
    expect(userId, 'user-123');
  });

  test('should reject empty email', () async {
    //Given
    final repository = FakeAuthRepository();
    final useCase = SignUpUseCase(repository);

    //When & Then
    await expectLater(
        useCase.execute(
            email: '',
            password: 'password123',
            confirmPassword: 'password123',
        ),
        throwsA(isA<InvalidEmailException>()),
    );
  });

  test('should reject empty password', () async {
    //Given
    final repository = FakeAuthRepository();
    final useCase = SignUpUseCase(repository);

    //When
    await expectLater(
      useCase.execute(
        email: 'hakim@example.com',
        password: '',
        confirmPassword: '',
      ),
      throwsA(isA<InvalidPasswordException>()),
    );
  });

  test('should reject empty password confirmation', () async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignUpUseCase(repository);

    // When
    await expectLater(
      useCase.execute(
        email: 'hakim@example.com',
        password: 'password123',
        confirmPassword: '',
      ),
      throwsA(isA<InvalidPasswordConfirmationException>()),
    );
  });

  test('should reject mismatching passwords', () async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignUpUseCase(repository);

    // When
    await expectLater(
      useCase.execute(
        email: 'hakim@example.com',
        password: 'password123',
        confirmPassword: 'password456',
      ),
      throwsA(isA<PasswordMismatchException>()),
    );
  });
}