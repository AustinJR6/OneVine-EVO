import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
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

  Future<void> incrementReligionPoints(String religionId, int points) {
    return _db
        .collection('religions')
        .doc(religionId)
        .update({'totalPoints': FieldValue.increment(points)});
  }

  Future<void> incrementOrganizationPoints(String organizationId, int points) {
    return _db
        .collection('organizations')
        .doc(organizationId)
        .update({'totalPoints': FieldValue.increment(points)});
  }
}
