import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final String challengeText;
  final bool completed;
  final bool skipped;
  final Timestamp timestampAssigned;
  final Timestamp? timestampCompleted;
  final int skipCost;

  DailyChallenge({
    required this.challengeText,
    required this.completed,
    required this.skipped,
    required this.timestampAssigned,
    this.timestampCompleted,
    required this.skipCost,
  });

  // Factory constructor to create a DailyChallenge from a Firestore document
  factory DailyChallenge.fromDocument(DocumentSnapshot doc) {
    return DailyChallenge(
      challengeText: doc['challengeText'] ?? '',
      completed: doc['completed'] ?? false,
      skipped: doc['skipped'] ?? false,
      timestampAssigned: doc['timestampAssigned'] ?? Timestamp.now(),
      timestampCompleted: doc['timestampCompleted'],
      skipCost: doc['skipCost'] ?? 0,
    );
  }

  // Method to convert a DailyChallenge to a Firestore document
  Map<String, dynamic> toDocument() {
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
