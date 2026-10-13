import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:save_plus_one/features/auth/domain/entities/user.dart';

class FirestoreUserDataSource {
    final FirebaseFirestore firestore;
    
    FirestoreUserDataSource(this.firestore);

    Future<User> create({
        required String id,
        required String email,
        required String displayName,
    }) async {
        final now = DateTime.now();
     
        final user = User(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: now,
            updatedAt: now,
        );

        await firestore.collection('users').doc(id).set({
            'email': email,
            'displayName': displayName,
            'createdAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
        });
        return user;
    }
}