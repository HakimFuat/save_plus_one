import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
    FirebaseFirestore,
    CollectionReference<Map<String, dynamic>>,
    DocumentReference<Map<String, dynamic>>,
    DocumentSnapshot<Map<String, dynamic>>,
    SetOptions,
])

void main() {}