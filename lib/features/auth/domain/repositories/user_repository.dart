import 'package:save_plus_one/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> create({
    required String id,
    required String email,
    required String displayName,
  });
}