import 'package:save_plus_one/features/auth/data/datasources/auth_data_source.dart';
import 'package:save_plus_one/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
    final AuthDataSource dataSource;

    FirebaseAuthRepository(this.dataSource);

    @override
    Future<String> signIn({
        required String email,
        required String password,
    }) {
        return dataSource.signIn(
            email: email,
            password: password,
        );
    }

    @override
    Future<String?> currentUserId() {
        return dataSource.currentUserId();
    }
}