import 'package:flutter_test/flutter_test.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';

void main() {
    test('should create user with valid data', () async {
        // Given
        final createdAt = DateTime(2026, 10, 3);
        final updatedAt = DateTime(2026, 10, 3);

        // When
        final user = User(
            id: 'user-123',
            email: 'hakim@example.com',
            displayName: 'Hakim',
            createdAt: createdAt,
            updatedAt: updatedAt,
        );

        // Then
        expect(user.id, 'user-123');
        expect(user.email, 'hakim@example.com');
        expect(user.displayName, 'Hakim');
        expect(user.createdAt, createdAt);
        expect(user.updatedAt, updatedAt);
    });

    test('should reject an empty user id', () {
        // Given
        final createdAt = DateTime(2026, 10, 3);
        final updatedAt = DateTime(2026, 10, 3);

        // When & Then
        expect(
            () => User(
                id: '',
                email: 'hakim@example.com',
                displayName: 'Hakim',
                createdAt: createdAt,
                updatedAt: updatedAt,
            ),
            throwsA(isA<ArgumentError>()),
        );
    });

    test('should reject an empty user email', () {
        // Given
        final createdAt = DateTime(2026, 10, 3);
        final updatedAt = DateTime(2026, 10, 3);

        // When / Then
        expect(
            () => User(
                id: 'user-123',
                email: '',
                displayName: 'Hakim',
                createdAt: createdAt,
                updatedAt: updatedAt,
            ),
            throwsA(isA<ArgumentError>()),
        );
    });

    test('should reject an empty display name', () {
        // Given
        final createdAt = DateTime(2026, 10, 3);
        final updatedAt = DateTime(2026, 10, 3);

        // When / Then
        expect(
            () => User(
                id: 'user-123',
                email: 'hakim@example.com',
                displayName: '',
                createdAt: createdAt,
                updatedAt: updatedAt,
            ),
            throwsA(isA<ArgumentError>()),
        );
    });
}