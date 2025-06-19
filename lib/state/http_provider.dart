import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';

const _defaultBaseUrl =
    String.fromEnvironment('FUNCTION_BASE_URL', defaultValue: 'https://us-central1-wwjd-app.cloudfunctions.net');

final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService(baseUrl: _defaultBaseUrl);
});
