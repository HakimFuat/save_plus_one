import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/data/repositories/firebase_auth_repository.dart';

import 'fakes/fake_auth_data_source.dart';

void main() {
  test('should return authenticated user id from data source', ()async {
    //Given
    final dataSource = FakeAuthDataSource();
    final repository = FirebaseAuthRepository(dataSource);

    //When
    final userId = await repository.signIn(email: 'hakim@example.com', password: 'password123',);

    //Then
    expect(userId, 'user-123');
  });

  test('should return current user id from data source', () async {
    final dataSource = FakeAuthDataSource();
    final repository = FirebaseAuthRepository(dataSource);

    final userId = await repository.currentUserId();

    expect(userId, 'user-123');
  });

  test('should sign out through data source', () async {
    final dataSource = FakeAuthDataSource();
    final repository = FirebaseAuthRepository(dataSource);

    await repository.signOut();

    expect(dataSource.signOutCalled, isTrue);
  });
}