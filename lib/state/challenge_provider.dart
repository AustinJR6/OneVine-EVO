import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_challenge.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_provider.dart';

class ChallengeProvider with ChangeNotifier {
  final UserService _userService;

  DailyChallenge? _dailyChallenge;
  int _tokenCount = 0;
  int _weeklySkipCount = 0;

  DailyChallenge? get dailyChallenge => _dailyChallenge;
  int get tokenCount => _tokenCount;
  int get weeklySkipCount => _weeklySkipCount;

  ChallengeProvider(this._userService);

  // Fetch initial data: daily challenge, user data (tokens, skips)
  Future<void> initializeChallengeData() async {
    await fetchUserData();
    await fetchDailyChallengeForToday();
    notifyListeners();
  }

  // Fetch today's daily challenge
  Future<void> fetchDailyChallengeForToday() async {
    // Check and reset weekly skips before fetching challenge
    await _userService.checkAndResetWeeklySkips();
    _dailyChallenge = await _userService.getDailyChallenge(); // This method already handles assignment if needed
    notifyListeners();
  }

  // Fetch user data (tokens, skips)
  Future<void> fetchUserData() async {
    await _updateUserDataFromService();
  }

  Future<void> completeChallenge() async {
    if (_dailyChallenge != null && !_dailyChallenge!.completed && !_dailyChallenge!.skipped) {
      await _userService.completeDailyChallenge();
      // TODO: Implement token awarding logic and update _tokenCount
      await fetchDailyChallenge(); // Refresh challenge status
      await _updateUserDataFromService(); // Refresh token count
    }
  }

  Future<void> skipChallenge() async {
     if (_dailyChallenge != null && !_dailyChallenge!.completed && !_dailyChallenge!.skipped) {
      // Skip logic is handled within UserService.skipDailyChallenge,
      // including token deduction and weekly skip count update.
      await _userService.skipDailyChallenge();
      await fetchDailyChallenge(); // Refresh challenge status
      await _updateUserDataFromService(); // Refresh token count and skip count
    }
  }

  // Helper method to update user data from the service
  Future<void> _updateUserDataFromService() async {
     final user = _userService.getCurrentUser(); // Use a public getter
    if (user != null) {
      final userData = await _userService.getUserData(user.uid);
      if (userData != null) {
        _tokenCount = userData.tokenBalance;
        _weeklySkipCount = userData.weeklySkipCount;
      }
    }
     notifyListeners();
  }

    // Call this method in the ChallengeScreen or where needed to trigger data fetch
  Future<void> loadChallengeData() async {
    await initializeChallengeData();
  }

  // Method to reset weekly skips - likely called on a timer or app open
  Future<void> resetWeeklySkips() async {
     final user = _userService._auth.currentUser;
      if (user != null) {
       await _userService.resetWeeklySkipCount(user.uid);
       _weeklySkipCount = 0;
       notifyListeners();
     }
  }

}
final challengeProviderProvider = ChangeNotifierProvider<ChallengeProvider>((ref) {
  final userService = ref.read(userServiceProvider);
  return ChallengeProvider(userService);
});
