import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import '../state/http_provider.dart';
import '../services/http_service.dart';

class ReligionAIState {
  final String question;
  final String response;
  final bool loading;
  final String? error;

  const ReligionAIState({
    this.question = '',
    this.response = '',
    this.loading = false,
    this.error,
  });

  ReligionAIState copyWith({
    String? question,
    String? response,
    bool? loading,
    String? error,
  }) {
    return ReligionAIState(
      question: question ?? this.question,
      response: response ?? this.response,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ReligionAINotifier extends StateNotifier<ReligionAIState> {
  ReligionAINotifier(this.ref) : super(const ReligionAIState());
  final Ref ref;

  void updateQuestion(String q) {
    state = state.copyWith(question: q);
  }

  Future<void> askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;
    final userData = await ref.read(firestoreServiceProvider).getUser(user.uid);
    if (userData == null) return;

    state = state.copyWith(loading: true, error: null, question: trimmed);
    try {
      final httpService = ref.read(httpServiceProvider);
      final idToken = await auth.currentUser?.getIdToken();
      final data = await httpService.post('askGeminiV2', {
        'history': [
          {'role': 'user', 'text': trimmed}
        ],
        'religion': userData.religion ?? 'spiritual',
      }, idToken: idToken);

      state = state.copyWith(
        response: data['text'] as String? ?? '',
        loading: false,
      );
    } on HttpServiceException catch (e) {
      state = state.copyWith(error: e.message, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final religionAIProvider =
    StateNotifierProvider<ReligionAINotifier, ReligionAIState>((ref) {
  return ReligionAINotifier(ref);
});
