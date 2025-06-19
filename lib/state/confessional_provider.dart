import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/functions_service.dart';
import 'functions_provider.dart';

class ConfessionalProvider extends ChangeNotifier {
  ConfessionalProvider(this._functions);

  final FunctionsService _functions;

  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => List.unmodifiable(_messages);
  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> sendMessage({required String text, required String religion}) async {
    _messages.add({'role': 'user', 'text': text});
    _loading = true;
    notifyListeners();
    try {
      final response = await _functions.askGemini(
        history: _messages,
        religion: religion,
      );
      _messages.add({'role': 'bot', 'text': response});
    } catch (e) {
      _messages.add({'role': 'bot', 'text': 'Error: $e'});
    }
    _loading = false;
    notifyListeners();
  }
}

final confessionalProvider = ChangeNotifierProvider<ConfessionalProvider>((ref) {
  final functions = ref.read(functionsServiceProvider);
  return ConfessionalProvider(functions);
});
