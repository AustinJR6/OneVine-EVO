import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  const key = String.fromEnvironment('GEMINI_API_KEY');
  return GeminiService(apiKey: key);
});
