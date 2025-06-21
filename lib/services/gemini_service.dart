import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Service for interacting with the Google Gemini REST API.
class GeminiService {
  GeminiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  final _log = Logger('GeminiService');

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> _post(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl?key=$apiKey');
    _log.fine('Sending request to $uri');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;
      return text ?? '';
    }
    _log.warning('Gemini error: ${res.statusCode} - ${res.body}');
    throw Exception('Gemini request failed (${res.statusCode})');
  }

  /// Generate text from a simple prompt.
  Future<String> generateText(String prompt) {
    return _post({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    });
  }

  /// Generate a response from a conversation history.
  Future<String> chat(List<Map<String, String>> history, String religion) async {
    final conversation = history.map((m) => "${m['role']}: ${m['text']}").join('\n');
    final prompt =
        'Act as a spiritual guide of $religion. Continue the conversation:\n$conversation';
    return generateText(prompt);
  }

  /// Generate a daily challenge for a given religion.
  Future<String> generateChallenge(String religion) async {
    final prompt =
        'Provide a short daily challenge for a follower of $religion.';
    return generateText(prompt);
  }

  /// Generate text with optional inline image data.
  Future<String> generateTextWithImage({required String prompt, List<int>? imageData}) {
    final parts = [
      {'text': prompt},
      if (imageData != null)
        {
          'inlineData': {
            'mimeType': 'image/png',
            'data': base64Encode(imageData),
          }
        }
    ];
    return _post({
      'contents': [
        {'parts': parts}
      ]
    });
  }
}
