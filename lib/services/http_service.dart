import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Exception thrown when a HTTP call fails.
class HttpServiceException implements Exception {
  /// Human readable message to present to the user.
  final String message;

  /// Optional status code returned by the server.
  final int? statusCode;

  HttpServiceException(this.message, [this.statusCode]);

  @override
  String toString() =>
      statusCode != null ? '$statusCode: $message' : 'HttpServiceException: $message';
}

class HttpService {
  final String baseUrl;

  HttpService({required this.baseUrl});

  /// Sends a POST request and returns the decoded JSON body on success.
  ///
  /// Throws [HttpServiceException] for any error, including non-200 responses
  /// and network issues.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? idToken,
    Map<String, String>? headers,
  }) async {
    idToken ??= await FirebaseAuth.instance.currentUser?.getIdToken();

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };

    final uri = Uri.parse('$baseUrl/$path');
    try {
      final response = await http
          .post(uri, headers: requestHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final status = response.statusCode;
      final bodyStr = response.body.isNotEmpty ? response.body : '{}';

      final data = jsonDecode(bodyStr) as Map<String, dynamic>;

      if (status >= 200 && status < 300) {
        return data;
      }

      final errorMsg = data['error']?.toString() ??
          data['message']?.toString() ??
          (data['error'] is Map ? data['error']['message']?.toString() : null) ??
          response.reasonPhrase ??
          'Request failed';
      throw HttpServiceException(errorMsg, status);
    } on SocketException {
      throw HttpServiceException('Network error. Please check your connection.');
    } on TimeoutException {
      throw HttpServiceException('Connection timed out.');
    } on FormatException {
      throw HttpServiceException('Invalid response format.');
    } catch (e) {
      if (e is HttpServiceException) rethrow;
      throw HttpServiceException(e.toString());
    }
  }
}
