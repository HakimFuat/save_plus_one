import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/application/sign_in.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/authentication_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_email_exception.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/invalid_password_exception.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  test('should return authenticated user id with valid credentials', () async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignInUseCase(repository);

    const email = 'hakim@example.com';
    const password = 'password123';

    // When
    final userId = await useCase.execute(
      email: email,
      password: password,
    );

    // Then
    expect(userId, 'user-123');
  });

  test('should reject invalid credentials',() async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignInUseCase(repository);

    const email = 'invalid@example.com';
    const password = 'wrong';

    // When & Then
    expect(
      () => useCase.execute(email: email, password: password),
      throwsA(isA<AuthenticationException>()),
    );
  });

  test('should reject empty email', () async {
    // Given
    final repository = FakeAuthRepository();
    final useCase = SignInUseCase(repository);

    const email = '';
    const password = 'password123';

    // When & Then
    expect(
      () => useCase.execute(
        email: email,
        password: password,
      ),
      throwsA(isA<InvalidEmailException>())
    );
  });

  test('should reject empty password', () async {
    //Given
    final repository = FakeAuthRepository();
    final useCase = SignInUseCase(repository);

    const email = 'hakim@example.com';
    const password = '';

    //When & Then
    expect(
      () => useCase.execute(
        email: email,
        password: password,
      ),
      throwsA(isA<InvalidPasswordException>()),
    );
  });
}