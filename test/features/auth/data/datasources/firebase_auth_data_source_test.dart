import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:mockito/mockito.dart';

import 'mocks/firebase_auth_mock.mocks.dart';

void main() {
    test('should return authenticated user id when credentials are valid', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();
        final userCredential = MockUserCredential();
        final user = MockUser();

        when(
            firebaseAuth.signInWithEmailAndPassword(
                email: 'hakim@example.com',
                password: 'password123',
            ),
        ).thenAnswer((_) async => userCredential);

        when(userCredential.user).thenReturn(user);
        when(user.uid).thenReturn('user-123');

        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        //When
        final userId = await dataSource.signIn(
            email: 'hakim@example.com',
            password: 'password123'
        );

        //Then
        expect(userId, 'user-123');
    });

    test('should return current user id when user is authenticated', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();
        final user = MockUser();

        when(firebaseAuth.currentUser).thenReturn(user);
        when(user.uid).thenReturn('user-123');

        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        //When
        final userId = await dataSource.currentUserId();

        //Then
        expect(userId, 'user-123');
    });
    
    test('should return null when no user is authenticated', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();

        when(firebaseAuth.currentUser).thenReturn(null);

        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        //When
        final userId = await dataSource.currentUserId();

        //Then
        expect(userId, isNull);
    });

    test('should sign out from Firebase Auth', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();
        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        //When
        await dataSource.signOut();

        //Then
        verify(firebaseAuth.signOut()).called(1);
    });

    test('should create Firebase account and return user id', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();
        final userCredential = MockUserCredential();
        final user = MockUser();

        when(
            firebaseAuth.createUserWithEmailAndPassword(
                email: 'hakim@example.com',
                password: 'password123',
            ),
        ).thenAnswer((_) async => userCredential);

        when(userCredential.user).thenReturn(user);
        when(user.uid).thenReturn('user-123');

        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        //When
        final userId = await dataSource.signUp(
            email: 'hakim@example.com',
            password: 'password123',
        );

        //Then
        expect(userId, 'user-123');
        verify(
            firebaseAuth.createUserWithEmailAndPassword(
                email: 'hakim@example.com',
                password: 'password123',
            ),
        ).called(1);
    });
}