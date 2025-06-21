import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_challenge.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';

final dailyChallengeStatusProvider = FutureProvider<DailyChallenge?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  final user = auth.currentUser;
  if (user == null) return null;
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final data = await firestore.getDocument('users/${user.uid}/dailyChallenges/$todayStr');
  return data != null ? DailyChallenge.fromMap(data) : null;
});
