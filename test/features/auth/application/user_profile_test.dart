
import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';
import 'package:save_plus_one/features/auth/domain/repositories/user_repository.dart';
import 'package:save_plus_one/features/auth/application/create_user_profile.dart';

class FakeUserRepository implements UserRepository {
  final DateTime createdAt = DateTime(2026, 10, 12, 10);
  final DateTime updatedAt = DateTime(2026, 10, 12, 11);
  bool shouldFail = false;

  @override
  Future<User> create({
    required String id,
    required String email,
    required String displayName,
  }) async {
    if (shouldFail) {
      throw Exception('Failed to create user profile');
    }
    return User(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

void main() {
  test('should create and return a saved user profile', () async {
    final repository = FakeUserRepository();
    final useCase = CreateUserProfileUseCase(repository);

    final user = await useCase.execute(
      id: 'user-123',
      email: 'hakim@example.com',
      displayName: 'Hakim',
    );

    expect(user.id, 'user-123');
    expect(user.email, 'hakim@example.com');
    expect(user.displayName, 'Hakim');
    expect(user.createdAt, repository.createdAt);
    expect(user.updatedAt, repository.updatedAt);
  });

  test('should propegate an error when profile creation fails', () async {
    final repository = FakeUserRepository();
    final useCase = CreateUserProfileUseCase(repository);

    repository.shouldFail = true;

    await expectLater(
      useCase.execute(
        id: 'user-123',
        email: 'hakim@example.com',
        displayName: 'Hakim',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
