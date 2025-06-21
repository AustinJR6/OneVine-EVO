import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/daily_challenge.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'functions_service.dart';

class UserService with ChangeNotifier {
  final AuthService _auth;
  final FirestoreService _firestore;
  final FunctionsService _functions;

  UserService(this._auth, this._firestore, this._functions);

  AuthUser? get currentFirebaseUser => _auth.currentUser;

  Future<void> checkAndResetWeeklySkips() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _checkAndResetWeeklySkips(user.uid);
    }
  }

  Future<DailyChallenge?> getDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await _checkAndResetWeeklySkips(user.uid);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final path = 'users/${user.uid}/dailyChallenges/$todayStr';
    final data = await _firestore.getDocument(path);
    if (data != null) {
      return DailyChallenge.fromMap(data);
    } else {
      await assignDailyChallenge();
      final updated = await _firestore.getDocument(path);
      return updated != null ? DailyChallenge.fromMap(updated) : null;
    }
  }

  Future<void> assignDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final userData = await getUserData(user.uid);
    final weeklySkips = userData?.weeklySkipCount ?? 0;
    final skipCost = weeklySkips == 0 ? 0 : 1 << (weeklySkips - 1);
    final challengeText = await _functions.getDailyChallenge(religion: 'Christian');
    final challenge = DailyChallenge(
      challengeText: challengeText,
      completed: false,
      skipped: false,
      timestampAssigned: DateTime.now(),
      skipCost: skipCost,
    );
    await _firestore.setDocument('users/${user.uid}/dailyChallenges/$todayStr', challenge.toMap());
    notifyListeners();
  }

  Future<void> completeDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await _firestore.updateDocumentPath('users/${user.uid}/dailyChallenges/$todayStr', {
      'completed': true,
      'timestampCompleted': DateTime.now(),
    });
    final data = await getUserData(user.uid);
    final tokens = data?.tokenBalance ?? 0;
    await _firestore.updateUser(user.uid, {'tokenBalance': tokens + 3});
    notifyListeners();
  }

  Future<void> skipDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final data = await getUserData(user.uid);
    final tokens = data?.tokenBalance ?? 0;
    final weeklySkips = data?.weeklySkipCount ?? 0;
    final lastSkipReset = data?.lastSkipReset;
    int cost = 0;
    if (weeklySkips > 0) cost = 1 << (weeklySkips - 1);
    if (tokens < cost) return;
    await _firestore.updateDocumentPath('users/${user.uid}/dailyChallenges/$todayStr', {
      'skipped': true,
    });
    await _firestore.updateUser(user.uid, {
      'tokenBalance': tokens - cost,
      'weeklySkipCount': weeklySkips + 1,
      'lastSkipReset': lastSkipReset != null && today.difference(lastSkipReset).inDays < 7 ? lastSkipReset : DateTime.now(),
    });
    notifyListeners();
  }

  Future<void> _checkAndResetWeeklySkips(String uid) async {
    final data = await getUserData(uid);
    final last = data?.lastSkipReset;
    final now = DateTime.now();
    if (last != null && now.difference(last).inDays >= 7) {
      await resetWeeklySkipCount(uid);
    }
    notifyListeners();
  }

  Future<User?> getUserData(String uid) async {
    final doc = await _firestore.getDocument('users/$uid');
    return doc != null ? User.fromMap(doc, uid) : null;
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.updateUser(uid, data);
    notifyListeners();
  }

  Future<void> resetWeeklySkipCount(String uid) async {
    await _firestore.updateUser(uid, {
      'weeklySkipCount': 0,
      'lastSkipReset': DateTime.now(),
    });
    notifyListeners();
  }
}
