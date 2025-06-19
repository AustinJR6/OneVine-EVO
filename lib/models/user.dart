import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final List<Map<String, dynamic>> journalEntries;
  final int tokenBalance;
  final Map<String, dynamic> dailyChallengeStatus; // This might be redundant with the new dailyChallenges subcollection, consider removing or refactoring
  final int weeklySkipCount;
  final Timestamp? lastSkipReset;

  User({
    required this.uid,
    required this.journalEntries,
    required this.tokenBalance,
    required this.dailyChallengeStatus,
    required this.weeklySkipCount,
    this.lastSkipReset,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      journalEntries: (data['journalEntries'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      tokenBalance: data['tokenBalance'] ?? 0,
      dailyChallengeStatus: data['dailyChallengeStatus'] as Map<String, dynamic>? ?? {}, // Consider refactoring this
      weeklySkipCount: data['weeklySkipCount'] ?? 0,
      lastSkipReset: data['lastSkipReset'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'journalEntries': journalEntries,
      'tokenBalance': tokenBalance,
      'dailyChallengeStatus': dailyChallengeStatus, // Consider refactoring this
      'weeklySkipCount': weeklySkipCount,
      'lastSkipReset': lastSkipReset,
    };
  }
}
