import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart';
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
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return null;
    return await ref.read(firestoreServiceProvider).getUser(user.uid);
  }

  Future<void> fetchChallenge() async {
    final userData = await _currentUser();
    if (userData == null) return;

    final last = userData.lastChallenge?.toDate();
    if (last != null && DateTime.now().difference(last).inHours < 24 && userData.lastChallengeText != null) {
      state = state.copyWith(challengeText: userData.lastChallengeText);
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final functions = ref.read(functionsServiceProvider);
      final challenge = await functions.getDailyChallenge(religion: userData.religion ?? 'spiritual');
      await ref.read(firestoreServiceProvider).updateUser(userData.uid, {
        'lastChallenge': Timestamp.now(),
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
    final userData = await _currentUser();
    if (userData == null) return;
    if (userData.tokenCount < 3) {
      state = state.copyWith(error: 'Not enough tokens');
      return;
    }
    await ref.read(firestoreServiceProvider)
        .updateUser(userData.uid, {'tokenCount': userData.tokenCount - 3});
    await fetchChallenge();
  }

  Future<void> handleComplete() async {
    final userData = await _currentUser();
    if (userData == null) return;
    final firestore = ref.read(firestoreServiceProvider);
    final functions = ref.read(functionsServiceProvider);
    final newStreak = userData.streak + 1;
    await firestore.updateUser(userData.uid, {
      'streak': newStreak,
      'tokenCount': userData.tokenCount + 1,
      'individualPoints': userData.individualPoints + 5,
    });

    if ([3,7,14,30].contains(newStreak) && !(userData.streakMilestones['$newStreak'] == true)) {
      await firestore.updateUser(userData.uid, {'streakMilestones.$newStreak': true});
      await functions.getMilestoneBlessing(religion: userData.religion ?? 'spiritual', streak: newStreak);
    }

    if (userData.religion != null) {
      await firestore.incrementReligionPoints(userData.religion!, 5);
    }
    if (userData.organizationId != null) {
      await firestore.incrementOrganizationPoints(userData.organizationId!, 5);
    }

    state = state.copyWith();
  }
}

final dailyChallengeProvider =
    StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  return DailyChallengeNotifier(ref);
});
