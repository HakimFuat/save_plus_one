import 'package:save_plus_one/features/auth/data/datasources/auth_data_source.dart';

class FakeAuthDataSource implements AuthDataSource {
  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    return 'user-123';
  }

  @override
  Future<String?> currentUserId() async {
    return 'user-123';
  }
}