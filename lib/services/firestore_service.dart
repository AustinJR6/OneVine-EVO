import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<app.User?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return app.User.fromFirestore(doc);
    }
    return null;
  }

  Stream<app.User?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return app.User.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> createUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(data);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).update(data);
  }
}
