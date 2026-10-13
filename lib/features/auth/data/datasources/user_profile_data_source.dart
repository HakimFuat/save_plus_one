import 'package:save_plus_one_/features/auth/domain/entities/user.dart';

abstract class UserProfileDataSource {
    Future<User> create({
        required String id,
        required String email,
        required String displayName,
        required DateTime createdAt,
        required DateTime updatedAt,
    });
}