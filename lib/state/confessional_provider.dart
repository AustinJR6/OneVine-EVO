import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../state/http_provider.dart';
import '../services/firestore_service.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';

class ConfessionalState {
  final List<Map<String, String>> messages;
  final bool loading;
  final String input;
  final String? error;

  const ConfessionalState({
    this.messages = const [],
    this.loading = false,
    this.input = '',
    this.error,
  });

  ConfessionalState copyWith({
    List<Map<String, String>>? messages,
    bool? loading,
    String? input,
    String? error,
  }) {
    return ConfessionalState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      input: input ?? this.input,
      error: error,
    );
  }
}

class ConfessionalNotifier extends StateNotifier<ConfessionalState> {
  ConfessionalNotifier(this.ref) : super(const ConfessionalState());

  final Ref ref;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    if (user == null) return;
    final firestore = ref.read(firestoreServiceProvider);
    final userData = await firestore.getUser(user.uid);
    if (userData == null) return;

    final newMessages = [...state.messages, {'role': 'user', 'text': text}];
    state = state.copyWith(messages: newMessages, loading: true, input: '');

    if (userData.tokenCount <= 0) {
      state = state.copyWith(loading: false, error: 'Out of tokens');
      return;
    }

    await firestore.updateUser(user.uid, {'tokenCount': userData.tokenCount - 1});

    try {
      final conversation = newMessages
          .map((m) => "${m['role']}: ${m['text']}")
          .join('\n');
      final idToken = await auth.currentUser?.getIdToken();
      final httpService = ref.read(httpServiceProvider);
      final res = await httpService.post('askGeminiV2', {
        'conversation': conversation,
        'religion': userData.religion ?? 'spiritual',
      }, idToken: idToken);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final reply = data['text'] as String? ?? '';
        state = state.copyWith(
          messages: [...newMessages, {'role': 'ai', 'text': reply}],
          loading: false,
        );
      } else {
        state = state.copyWith(
          messages: [...newMessages, {'role': 'ai', 'text': 'Error ${res.statusCode}'}],
          loading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        messages: [...newMessages, {'role': 'ai', 'text': 'Error: $e'}],
        loading: false,
      );
    }
  }
}

final confessionalProvider =
    StateNotifierProvider<ConfessionalNotifier, ConfessionalState>((ref) {
  return ConfessionalNotifier(ref);
});
