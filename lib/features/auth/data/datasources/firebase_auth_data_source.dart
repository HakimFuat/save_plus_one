import 'package:firebase_auth/firebase_auth.dart';
import 'package:save_plus_one/features/auth/data/datasources/auth_data_source.dart';

class FirebaseAuthDataSource implements AuthDataSource {
    final FirebaseAuth firebaseAuth;

    FirebaseAuthDataSource(this.firebaseAuth);

    @override
    Future<String> signIn({
        required String email,
        required String password,
    }) async {
        final credential = await firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
        );

        return credential.user!.uid;
    }

    @override
    Future<String?> currentUserId() async {
        return firebaseAuth.currentUser?.uid;
    }

    @override
    Future<void> signOut() {
        return firebaseAuth.signOut();
    }

    @override
    Future<String> signUp({
        required String email,
        required String password,
    }) async {
        final credential = await firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
        );

        return credential.user!.uid;
    }
}