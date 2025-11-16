import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  FirebaseFirestore get firestore => _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _firestore.collection(path);

  DocumentReference<Map<String, dynamic>> doc(String path) =>
      _firestore.doc(path);
}
