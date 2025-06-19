import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import 'auth_providers.dart';
import '../models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userDataProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) return Stream.value(null);
    return firestore.watchUser(user.uid);
  });
});

final tokenProvider = Provider<int>((ref) {
  final userData = ref.watch(userDataProvider).value;
  return userData?.tokenCount ?? 0;
});
