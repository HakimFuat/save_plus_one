import 'package:save_plus_one/features/auth/data/datasources/user_data_source.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';
import 'package:save_plus_one/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
    final UserDataSource dataSource;

    UserRepositoryImpl(this.dataSource);

    @override
    Future<User> create({
        required String id,
        required String email,
        required String displayName,
    }) {
        return dataSource.create(
            id: id,
            email: email,
            displayName: displayName,
        );
    }
}