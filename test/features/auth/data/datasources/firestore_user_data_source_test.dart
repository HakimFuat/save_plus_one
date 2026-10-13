import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';
import 'package:save_plus_one/features/auth/data/datasources/firestore_user_data_source.dart';

import 'mocks/firestore_mock.mocks.dart';


void main() {
    late MockFirebaseFirestore firestore;
    late MockCollectionReference<Map<String, dynamic>> userCollection;
    late MockDocumentReference<Map<String, dynamic>> userDocument;

    setUp(() {
        firestore = MockFirebaseFirestore();
        userCollection = MockCollectionReference<Map<String, dynamic>>();
        userDocument = MockDocumentReference<Map<String, dynamic>>();

        when(firestore.collection('users')).thenReturn(userCollection);
        when(userCollection.doc('user-123')).thenReturn(userDocument);
        when(userDocument.set(any)).thenAnswer((_) async {});
    });

    test('should save a profile to the document matching the user ID', () async {
        //Arrange
        final dataSource = FirestoreUserDataSource(firestore);

        //Act
        await dataSource.create(
            id: 'user-123',
            email: 'hakim@example.com',
            displayName: 'Hakim',
        );

        final captured = verify (userDocument.set(captureAny)).captured;
        final savedData = captured.single as Map<String, dynamic>;

        expect(savedData['email'], 'hakim@example.com');
        expect(savedData['displayName'], 'Hakim');
        expect(savedData['createdAt'], isA<Timestamp>());
        expect(savedData['updatedAt'], isA<Timestamp>());

        verify(firestore.collection('users')).called(1);
        verify(userCollection.doc('user-123')).called(1);
    });
}