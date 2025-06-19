import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> askGemini({required List<Map<String, String>> history, required String religion}) async {
    final result = await _functions.httpsCallable('askGeminiV2').call({
      'history': history,
      'religion': religion,
    });
    return result.data['text'] as String? ?? '';
  }

  Future<String> getDailyChallenge({required String religion}) async {
    final result = await _functions.httpsCallable('getDailyChallenge').call({
      'religion': religion,
    });
    return result.data['text'] as String? ?? '';
  }

  Future<String> getMilestoneBlessing({required String religion, required int streak}) async {
    final result = await _functions.httpsCallable('getMilestoneBlessing').call({
      'religion': religion,
      'streak': streak,
    });
    return result.data['text'] as String? ?? '';
  }
}
