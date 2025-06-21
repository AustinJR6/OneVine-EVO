import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini_provider.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import '../models/user_model.dart';

class DailyChallengeState {
  final bool loading;
  final String? challengeText;
  final String? error;

  const DailyChallengeState({this.loading = false, this.challengeText, this.error});

  DailyChallengeState copyWith({bool? loading, String? challengeText, String? error}) {
    return DailyChallengeState(
      loading: loading ?? this.loading,
      challengeText: challengeText ?? this.challengeText,
      error: error,
    );
  }
}

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier(this.ref) : super(const DailyChallengeState());

  final Ref ref;

  Future<UserModel?> _currentUser() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return null;
    return await ref.read(firestoreServiceProvider).getUser(user.uid);
  }

  Future<void> fetchChallenge() async {
    final userData = await _currentUser();
    if (userData == null) return;

    final last = userData.lastChallenge;
    final now = DateTime.now();
    if (last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day &&
        userData.lastChallengeText != null) {
      state = state.copyWith(challengeText: userData.lastChallengeText);
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final challenge = await gemini.generateChallenge(
        userData.religion ?? 'spiritual',
      );
      await ref.read(firestoreServiceProvider).updateUser(userData.uid, {
        'lastChallenge': DateTime.now(),
        'lastChallengeText': challenge,
      });
      state = DailyChallengeState(challengeText: challenge);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> handleSkip() async {
    final userData = ref.read(userDataProvider).value ?? await _currentUser();
    if (userData == null) return;
    if (userData.tokenCount < 3) {
      state = state.copyWith(error: 'Not enough tokens');
      return;
    }
    await ref
        .read(firestoreServiceProvider)
        .updateUser(userData.uid, {'tokenCount': userData.tokenCount - 3});
    await fetchChallenge();
  }

  Future<void> handleComplete() async {
    final userData = await _currentUser();
    if (userData == null) return;
    final firestore = ref.read(firestoreServiceProvider);
    final newStreak = userData.streak + 1;
    await firestore.updateUser(userData.uid, {
      'streak': newStreak,
      'tokenCount': userData.tokenCount + 1,
      'individualPoints': userData.individualPoints + 5,
    });

    if ([3,7,14,30].contains(newStreak) && !(userData.streakMilestones['$newStreak'] == true)) {
      await firestore.updateUser(userData.uid, {'streakMilestones.$newStreak': true});
      try {
        final gemini = ref.read(geminiServiceProvider);
        await gemini.generateText(
            'Offer a brief blessing from the perspective of ${userData.religion ?? 'spiritual'} for achieving a $newStreak-day streak.');
      } catch (_) {
        // Ignore blessing errors silently
      }
    }

    if (userData.religion != null) {
      await firestore.incrementReligionPoints(userData.religion!, 5);
    }
    if (userData.organizationId != null) {
      await firestore.incrementOrganizationPoints(userData.organizationId!, 5);
    }

    state = state.copyWith();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  return DailyChallengeNotifier(ref);
});

