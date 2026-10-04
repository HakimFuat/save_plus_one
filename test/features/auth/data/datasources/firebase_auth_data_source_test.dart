import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:save_plus_one/features/auth/domain/exceptions/authentication_exception.dart';
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

    test('should throw AuthenticationException when sign up fails', () async {
        //Given
        final firebaseAuth = MockFirebaseAuth();
        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        when(
            firebaseAuth.createUserWithEmailAndPassword(
                email: 'existing@example.com',
                password: 'password123',
            ),
        ).thenThrow(
            FirebaseAuthException(
                code: 'email-already-in-use',
            ),
        );

        //When & Then
        await expectLater(
            dataSource.signUp(
                email: 'existing@example.com',
                password: 'password123',
            ),
            throwsA(isA<AuthenticationException>()),
        );
    });

    test('should throw AuthenticationException when sign in fails', () async {
        //Given 
        final firebaseAuth = MockFirebaseAuth();
        final dataSource = FirebaseAuthDataSource(firebaseAuth);

        when(
            firebaseAuth.signInWithEmailAndPassword(
                email: 'wrong@example.com',
                password: 'wrongpassword',
            ),
        ).thenThrow(
            FirebaseAuthException(
                code: 'invalid-credential',
            ),
        );

        //When & Then
        await expectLater(
            dataSource.signIn(
                email: 'wrong@example.com',
                password: 'wrongpassword',
            ),
            throwsA(isA<AuthenticationException>()),
        );
    });
}