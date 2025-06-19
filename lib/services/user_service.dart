import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import Material for @required (or use required keyword)
import 'dart:math'; // Import for random selection

import '../models/user.dart'; // Assuming your User model is here
import '../models/daily_challenge.dart'; // Assuming your DailyChallenge model is here

class UserService with ChangeNotifier { // Added ChangeNotifier for Provider
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the users collection
  CollectionReference _usersCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('dailyChallenges');
  }

  // Reference to the user's profile document
  DocumentReference _userProfileDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Reference to the challenge pool configuration
  final DocumentReference _challengePoolDoc = FirebaseFirestore.instance.collection('config').doc('challengePool');

  // Method to get today's daily challenge
  Future<DailyChallenge?> getDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Check and reset weekly skip count if necessary
    await _checkAndResetWeeklySkips(user.uid);

    final today = DateTime.now();
    final todayDateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      final doc = await _usersCollection(user.uid).doc(todayDateString).get();

      if (doc.exists) {
        return DailyChallenge.fromDocument(doc);
      } else {
        // No challenge for today, assign a new one
        await assignDailyChallenge();
        // Fetch the newly assigned challenge
        final updatedDoc = await _usersCollection(user.uid).doc(todayDateString).get();
        return DailyChallenge.fromDocument(updatedDoc);
      }
    } catch (e) {
      print("Error getting daily challenge: $e");
      return null;
    }
  }

  // Method to assign a new daily challenge
  Future<void> assignDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayDateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      // --- Challenge Selection Logic ---
      final challengePoolSnapshot = await _challengePoolDoc.get();
      final challengePool = challengePoolSnapshot.data() as Map<String, dynamic>?;
      final List<String> challenges = List<String>.from(challengePool?['challenges'] ?? []);

      if (challenges.isEmpty) {
        print("Challenge pool is empty.");
        return;
      }

      // Fetch user's challenges for the last 30 days
      final past30Days = today.subtract(const Duration(days: 30));
      final recentChallengesSnapshot = await _usersCollection(user.uid)
          .where('timestampAssigned', isGreaterThanOrEqualTo: Timestamp.fromDate(past30Days))
          .get();

      final recentChallengeTexts = recentChallengesSnapshot.docs.map((doc) => doc['challengeText'] as String).toList();

      // Select a random challenge that hasn't been used recently
      final availableChallenges = challenges.where((challenge) => !recentChallengeTexts.contains(challenge)).toList();

      String selectedChallengeText;
      if (availableChallenges.isNotEmpty) {
        final random = Random();
        selectedChallengeText = availableChallenges[random.nextInt(availableChallenges.length)];
      } else {
        // If all challenges have been used recently, allow repetition
        final random = Random();
        selectedChallengeText = challenges[random.nextInt(challenges.length)];
      }

      // --- Skip Cost Calculation ---
      final userData = await getUserData(user.uid);
      int weeklySkips = userData?.weeklySkipCount ?? 0;
      int skipCost = weeklySkips == 0 ? 0 : 1 << (weeklySkips - 1); // Exponential skip cost (0 for first skip, then 1, 2, 4, ...)


      final newChallenge = DailyChallenge(
        challengeText: selectedChallengeText,
        completed: false,
        skipped: false,
        timestampAssigned: Timestamp.now(),
        skipCost: skipCost,
      );

      await _usersCollection(user.uid).doc(todayDateString).set(newChallenge.toDocument());

      // Notify listeners that challenge has been assigned
       notifyListeners();

    } catch (e) {
      print("Error assigning daily challenge: $e");
    }
  }

  // Method to mark challenge as completed
  Future<void> completeDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayDateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    try {
      await _usersCollection(user.uid).doc(todayDateString).update({
        'completed': true,
        'timestampCompleted': Timestamp.now(),
      });

      // --- Token Awarding Logic ---
      final userData = await getUserData(user.uid);
      int currentTokenBalance = userData?.tokenBalance ?? 0;
      const int tokensToAward = 3; // Configurable number of tokens

      await _userProfileDoc(user.uid).update({
        'tokenBalance': currentTokenBalance + tokensToAward,
      });

      // Notify listeners that challenge is completed and tokens updated
      notifyListeners();

    } catch (e) {
      print("Error completing daily challenge: $e");
      // TODO: Handle error in UI
    }
  }

  // Method to mark challenge as skipped
  Future<void> skipDailyChallenge() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayDateString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

     try {
      // --- Weekly Skip Reset Check ---
      await _checkAndResetWeeklySkips(user.uid);

      // --- Token Deduction and Weekly Skip Count Logic ---
      final userData = await getUserData(user.uid);
      int currentTokenBalance = userData?.tokenBalance ?? 0;
      int weeklySkips = userData?.weeklySkipCount ?? 0;
      final lastSkipReset = userData?.lastSkipReset?.toDate();

      int tokensToDeduct = 0;
      if (weeklySkips > 0) {
         tokensToDeduct = 1 << (weeklySkips - 1); // Exponential cost after the first skip
      }

      // Check if enough tokens are available
      if (currentTokenBalance < tokensToDeduct) {
        print("Not enough tokens to skip challenge.");
        // TODO: Handle insufficient tokens in UI (e.g., show a message)
        return;
      }

      await _usersCollection(user.uid).doc(todayDateString).update({
        'skipped': true,
      });

      // Deduct tokens if not a free skip
      if (tokensToDeduct > 0) {
         await _userProfileDoc(user.uid).update({
          'tokenBalance': currentTokenBalance - tokensToDeduct,
          'weeklySkipCount': weeklySkips + 1,
          'lastSkipReset': lastSkipReset != null && today.difference(lastSkipReset).inDays < 7
            ? Timestamp.fromDate(lastSkipReset) // Don't update reset time if within the week
            : Timestamp.now(), // Update reset time if a new week starts
        });
      } else {
        // It's a free skip
         await _userProfileDoc(user.uid).update({
          'weeklySkipCount': weeklySkips + 1,
           'lastSkipReset': lastSkipReset != null && today.difference(lastSkipReset).inDays < 7
            ? Timestamp.fromDate(lastSkipReset) // Don't update reset time if within the week
            : Timestamp.now(), // Update reset time if a new week starts
        });
      }

      // Notify listeners that challenge is skipped and tokens/skip count updated
      notifyListeners();

    } catch (e) {
      print("Error skipping daily challenge: $e");
      // TODO: Handle error in UI
    }
  }


  // Method to check and reset weekly skip count
  Future<void> _checkAndResetWeeklySkips(String uid) async {
      try {
      final userData = await getUserData(uid);
      final lastSkipReset = userData?.lastSkipReset?.toDate();
      final now = DateTime.now();

      if (lastSkipReset != null && now.difference(lastSkipReset).inDays >= 7) {
        await resetWeeklySkipCount(uid);
      }
       // Notify listeners if reset occurred
      notifyListeners();
    } catch (e) {
      print("Error checking and resetting weekly skips: $e");
    }
  }


  // Method to get user data
  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _userProfileDoc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  // Method to update user data (for tokens and skip count)
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _userProfileDoc(uid).update(data);
       notifyListeners(); // Notify listeners of user data changes
    } catch (e) {
      print("Error updating user data: $e");
    }
  }

  // Method to reset weekly skip count
  Future<void> resetWeeklySkipCount(String uid) async {
     try {
      await _userProfileDoc(uid).update({
        'weeklySkipCount': 0,
        'lastSkipReset': Timestamp.now(),
      });
       notifyListeners(); // Notify listeners of skip count reset
    } catch (e) {
      print("Error resetting weekly skip count: $e");
    }
  }
}
