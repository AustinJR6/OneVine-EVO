class User {
  final String uid;
  final List<Map<String, dynamic>> journalEntries;
  final int tokenBalance;
  final Map<String, dynamic> dailyChallengeStatus;
  final int weeklySkipCount;
  final DateTime? lastSkipReset;

  User({
    required this.uid,
    required this.journalEntries,
    required this.tokenBalance,
    required this.dailyChallengeStatus,
    required this.weeklySkipCount,
    this.lastSkipReset,
  });

  factory User.fromMap(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      journalEntries: (data['journalEntries'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      tokenBalance: data['tokenBalance'] as int? ?? 0,
      dailyChallengeStatus:
          Map<String, dynamic>.from(data['dailyChallengeStatus'] as Map? ?? {}),
      weeklySkipCount: data['weeklySkipCount'] as int? ?? 0,
      lastSkipReset: data['lastSkipReset'] as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'journalEntries': journalEntries,
      'tokenBalance': tokenBalance,
      'dailyChallengeStatus': dailyChallengeStatus,
      'weeklySkipCount': weeklySkipCount,
      'lastSkipReset': lastSkipReset,
    };
  }
}
