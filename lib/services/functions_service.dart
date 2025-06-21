import 'http_service.dart';

class FunctionsService {
  final HttpService _http;
  FunctionsService(this._http);

  Future<String> askGemini({required List<Map<String, String>> history, required String religion, String? idToken}) async {
    final data = await _http.post('askGeminiV2', {
      'history': history,
      'religion': religion,
    }, idToken: idToken);
    return data['text'] as String? ?? '';
  }

  Future<String> getDailyChallenge({required String religion, String? idToken}) async {
    final data = await _http.post('getDailyChallenge', {
      'religion': religion,
    }, idToken: idToken);
    return data['text'] as String? ?? '';
  }

  Future<String> getMilestoneBlessing({required String religion, required int streak, String? idToken}) async {
    final data = await _http.post('getMilestoneBlessing', {
      'religion': religion,
      'streak': streak,
    }, idToken: idToken);
    return data['text'] as String? ?? '';
  }
}
