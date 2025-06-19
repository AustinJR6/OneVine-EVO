import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import '../state/http_provider.dart';
import '../services/http_service.dart';

class TriviaState {
  final String? story;
  final String? storyId;
  final String? resultText;
  final bool loading;
  final String? error;
  const TriviaState({
    this.story,
    this.storyId,
    this.resultText,
    this.loading = false,
    this.error,
  });

  TriviaState copyWith({
    String? story,
    String? storyId,
    String? resultText,
    bool? loading,
    String? error,
  }) {
    return TriviaState(
      story: story ?? this.story,
      storyId: storyId ?? this.storyId,
      resultText: resultText ?? this.resultText,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class TriviaNotifier extends StateNotifier<TriviaState> {
  TriviaNotifier(this.ref) : super(const TriviaState());
  final Ref ref;

  Future<void> fetchTriviaQuestion() async {
    state = state.copyWith(loading: true, error: null, resultText: null);
    try {
      final httpService = ref.read(httpServiceProvider);
      final idToken = await ref.read(firebaseAuthProvider).currentUser?.getIdToken();
      final data = await httpService.post('getTriviaQuestion', {}, idToken: idToken);
      state = state.copyWith(
        story: data['story'] as String?,
        storyId: data['id'] as String?,
        loading: false,
      );
    } on HttpServiceException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> submitGuess(String religionGuess, String storyGuess) async {
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null || state.storyId == null) return;
    final firestore = ref.read(firestoreServiceProvider);
    final userData = await firestore.getUser(user.uid);
    if (userData == null) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final httpService = ref.read(httpServiceProvider);
      final idToken = await auth.currentUser?.getIdToken();
      final data = await httpService.post('validateTriviaAnswer', {
        'id': state.storyId,
        'religionGuess': religionGuess,
        'storyGuess': storyGuess,
      }, idToken: idToken);
      final score = (data['score'] as num?)?.toInt() ?? 0;
      await firestore.updateUser(user.uid, {
        'individualPoints': userData.individualPoints + score,
      });
      if (userData.religion != null) {
        await firestore.incrementReligionPoints(userData.religion!, score);
      }
      if (userData.organizationId != null) {
        await firestore.incrementOrganizationPoints(userData.organizationId!, score);
      }
      state = state.copyWith(resultText: data['resultText'] as String?, loading: false);
    } on HttpServiceException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final triviaProvider = StateNotifierProvider<TriviaNotifier, TriviaState>((ref) {
  return TriviaNotifier(ref);
});
