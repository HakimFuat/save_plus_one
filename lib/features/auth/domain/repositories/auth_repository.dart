abstract class AuthRepository {
  Future<String> signIn({
    required String email,
    required String password,
  });

  Future<String?> currentUserId();
  Future<void> signOut();
  Future<String> signUp({
    required String email,
    required String password,
  });
}