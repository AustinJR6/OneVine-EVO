import 'dart:convert';
import 'package:http/http.dart' as http;
class HttpService {
  final String baseUrl;

  HttpService({required this.baseUrl});

  Future<http.Response> post(String path, Map<String, dynamic> body,
      {String? idToken, Map<String, String>? headers}) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };

    final uri = Uri.parse('$baseUrl/$path');
    return http.post(uri, headers: requestHeaders, body: jsonEncode(body));
  }
}
