import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? religion;
  final String? organizationId;
  final int tokenCount;
  final int streak;
  final String? lastChallengeText;
  final Timestamp? lastChallenge;
  final int individualPoints;
  final Map<String, dynamic> streakMilestones;

  UserModel({
    required this.uid,
    this.religion,
    this.organizationId,
    required this.tokenCount,
    required this.streak,
    this.lastChallengeText,
    this.lastChallenge,
    required this.individualPoints,
    required this.streakMilestones,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      religion: data['religion'],
      organizationId: data['organizationId'],
      tokenCount: data['tokenCount'] ?? 0,
      streak: data['streak'] ?? 0,
      lastChallengeText: data['lastChallengeText'],
      lastChallenge: data['lastChallenge'],
      individualPoints: data['individualPoints'] ?? 0,
      streakMilestones: Map<String, dynamic>.from(data['streakMilestones'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'religion': religion,
      'organizationId': organizationId,
      'tokenCount': tokenCount,
      'streak': streak,
      'lastChallengeText': lastChallengeText,
      'lastChallenge': lastChallenge,
      'individualPoints': individualPoints,
      'streakMilestones': streakMilestones,
    };
  }
}
