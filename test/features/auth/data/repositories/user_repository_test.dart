import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';
import 'package:save_plus_one/features/auth/domain/repositories/user_repository.dart';
import 'package:save_plus_one/features/auth/data/repositories/user_repository_impl.dart';
import 'package:save_plus_one/features/auth/data/datasources/user_data_source.dart';

class FakeUserDataSource implements UserDataSource {
    User? createdUser;

    @override
    Future<User> create({
        required String id,
        required String email,
        required String displayName,
    }) async {
        final now = DateTime(2026, 10, 12);

        final user = User(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: now,
            updatedAt: now,
        );

        createdUser = user;
        return user;
    }
}

void main() {
    test('should delegate profile creation to data source', () async {
        final dataSource = FakeUserDataSource();
        final repository = UserRepositoryImpl(dataSource);

        final user = await repository.create(
            id: 'user-123',
            email: 'hakim@example.com',
            displayName: 'Hakim',
        );

        expect(dataSource.createdUser , isNotNull);
        expect(dataSource.createdUser!.id, 'user-123');
        expect(user.id, 'user-123');
        expect(user.email, 'hakim@example.com');
        expect(user.displayName, 'Hakim');
    });
}
