abstract class AuthDataSource {
    Future<String> signIn({
        required String email,
        required String password,
    });

    Future<String?> currentUserId();

    Future<void> signOut();
}