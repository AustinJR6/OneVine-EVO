import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import 'gemini_provider.dart';

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
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;
    final userData = await ref.read(firestoreServiceProvider).getUser(user.uid);
    if (userData == null) return;

    state = state.copyWith(loading: true, error: null, question: trimmed);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final text = await gemini.chat(
        [
          {'role': 'user', 'text': trimmed}
        ],
        userData.religion ?? 'spiritual',
      );

      state = state.copyWith(
        response: text,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final religionAIProvider =
    StateNotifierProvider<ReligionAINotifier, ReligionAIState>((ref) {
  return ReligionAINotifier(ref);
});
