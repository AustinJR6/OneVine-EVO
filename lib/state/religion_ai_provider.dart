import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import '../state/http_provider.dart';

class ReligionAIState {
  final String response;
  final bool loading;
  final String? error;
  const ReligionAIState({this.response = '', this.loading = false, this.error});

  ReligionAIState copyWith({String? response, bool? loading, String? error}) {
    return ReligionAIState(
      response: response ?? this.response,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ReligionAINotifier extends StateNotifier<ReligionAIState> {
  ReligionAINotifier(this.ref) : super(const ReligionAIState());
  final Ref ref;

  Future<void> askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;
    final userData = await ref.read(firestoreServiceProvider).getUser(user.uid);
    if (userData == null) return;

    state = state.copyWith(loading: true, error: null);
    try {
      final httpService = ref.read(httpServiceProvider);
      final res = await httpService.post('askGeminiV2', {
        'history': [
          {'role': 'user', 'text': trimmed}
        ],
        'religion': userData.religion ?? 'spiritual',
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        state = state.copyWith(response: data['text'] as String? ?? '', loading: false);
      } else {
        state = state.copyWith(error: 'Error ${res.statusCode}', loading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final religionAIProvider =
    StateNotifierProvider<ReligionAINotifier, ReligionAIState>((ref) {
  return ReligionAINotifier(ref);
});
