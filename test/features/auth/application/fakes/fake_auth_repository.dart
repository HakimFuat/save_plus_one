import 'package:save_plus_one/features/auth/domain/exceptions/authentication_exception.dart';
import 'package:save_plus_one/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (email == 'invalid@example.com' || password == 'wrong') {
      throw const AuthenticationException();
    }

    return 'user-123';
  }

  @override
  Future<String?> currentUserId() async {
    return null;
  }

  @override
  Future<void> signOut() async {}
}