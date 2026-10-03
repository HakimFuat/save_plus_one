abstract class AuthRepository {
  Future<String> signIn({
    required String email,
    required String password,
  });

  Future<String?> currentUserId();
}