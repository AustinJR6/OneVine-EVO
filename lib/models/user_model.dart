class UserModel {
  final String uid;
  final String? religion;
  final String? organizationId;
  final int tokenCount;
  final int streak;
  final String? lastChallengeText;
  final DateTime? lastChallenge;
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

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      religion: data['religion'] as String?,
      organizationId: data['organizationId'] as String?,
      tokenCount: (data['tokenCount'] as int?) ?? 0,
      streak: (data['streak'] as int?) ?? 0,
      lastChallengeText: data['lastChallengeText'] as String?,
      lastChallenge: data['lastChallenge'] as DateTime?,
      individualPoints: (data['individualPoints'] as int?) ?? 0,
      streakMilestones:
          Map<String, dynamic>.from(data['streakMilestones'] as Map? ?? {}),
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
