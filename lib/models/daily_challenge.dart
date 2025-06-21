class DailyChallenge {
  final String challengeText;
  final bool completed;
  final bool skipped;
  final DateTime timestampAssigned;
  final DateTime? timestampCompleted;
  final int skipCost;

  DailyChallenge({
    required this.challengeText,
    required this.completed,
    required this.skipped,
    required this.timestampAssigned,
    this.timestampCompleted,
    required this.skipCost,
  });

  factory DailyChallenge.fromMap(Map<String, dynamic> data) {
    return DailyChallenge(
      challengeText: data['challengeText'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
      skipped: data['skipped'] as bool? ?? false,
      timestampAssigned:
          data['timestampAssigned'] as DateTime? ?? DateTime.now(),
      timestampCompleted: data['timestampCompleted'] as DateTime?,
      skipCost: data['skipCost'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'challengeText': challengeText,
      'completed': completed,
      'skipped': skipped,
      'timestampAssigned': timestampAssigned,
      'timestampCompleted': timestampCompleted,
      'skipCost': skipCost,
    };
  }
}
