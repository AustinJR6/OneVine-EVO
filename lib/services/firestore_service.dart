import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_config.dart';
import 'auth_service.dart';
import '../models/user_model.dart';

class FirestoreService {
  final AuthService _auth;
  FirestoreService(this._auth);

  String get _baseUrl =>
      'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents';

  Map<String, String> _headers(String? idToken) => {
        'Content-Type': 'application/json',
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      };

  Map<String, dynamic> _wrapFields(Map<String, dynamic> data) {
    return {
      'fields': data.map((k, v) => MapEntry(k, _encodeValue(v)))
    };
  }

  Map<String, dynamic> _encodeValue(dynamic value) {
    if (value is int) {
      return {'integerValue': value.toString()};
    }
    if (value is double) {
      return {'doubleValue': value};
    }
    if (value is bool) {
      return {'booleanValue': value};
    }
    if (value is DateTime) {
      return {'timestampValue': value.toIso8601String()};
    }
    if (value is Map<String, dynamic>) {
      return {
        'mapValue': {'fields': value.map((k, v) => MapEntry(k, _encodeValue(v)))}
      };
    }
    return {'stringValue': value.toString()};
  }

  dynamic _decodeValue(Map<String, dynamic> value) {
    if (value.containsKey('stringValue')) {
      return value['stringValue'];
    }
    if (value.containsKey('integerValue')) {
      return int.tryParse(value['integerValue'] as String) ?? 0;
    }
    if (value.containsKey('doubleValue')) {
      return value['doubleValue'];
    }
    if (value.containsKey('booleanValue')) {
      return value['booleanValue'];
    }
    if (value.containsKey('timestampValue')) {
      return DateTime.parse(value['timestampValue']);
    }
    if (value.containsKey('mapValue')) {
      final fields = value['mapValue']['fields'] as Map<String, dynamic>? ?? {};
      return fields.map((k, v) => MapEntry(k, _decodeValue(v)));
    }
    return null;
  }

  Map<String, dynamic> _decodeFields(Map<String, dynamic> fields) {
    return fields.map((k, v) => MapEntry(k, _decodeValue(v)));
  }

  Future<Map<String, dynamic>?> getDocument(String path) async {
    final idToken = await _auth.getIdToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/$path'),
      headers: _headers(idToken),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>?;
      if (fields == null) {
        return null;
      }
      return _decodeFields(fields);
    }
    return null;
  }

  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    final idToken = await _auth.getIdToken();
    await http.patch(
      Uri.parse('$_baseUrl/$path'),
      headers: _headers(idToken),
      body: jsonEncode(_wrapFields(data)),
    );
  }

  Future<UserModel?> getUser(String uid) async {
    final idToken = await _auth.getIdToken();
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$uid'),
      headers: _headers(idToken),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>?;
      if (fields == null) {
        return null;
      }
      return UserModel.fromMap(_decodeFields(fields), uid);
    }
    return null;
  }

  Stream<UserModel?> watchUser(String uid) async* {
    while (true) {
      yield await getUser(uid);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    final idToken = await _auth.getIdToken();
    await http.patch(
      Uri.parse('$_baseUrl/users/$uid'),
      headers: _headers(idToken),
      body: jsonEncode(_wrapFields(data)),
    );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await createUser(uid, data);
  }

  Future<void> _increment(String collection, String docId, int points) async {
    final fields = await getDocument('$collection/$docId');
    final current = fields?['totalPoints'] as int? ?? 0;
    await updateDoc(collection, docId, {'totalPoints': current + points});
  }

  Future<void> updateDoc(
      String collection, String docId, Map<String, dynamic> data) async {
    final idToken = await _auth.getIdToken();
    await http.patch(
      Uri.parse('$_baseUrl/$collection/$docId'),
      headers: _headers(idToken),
      body: jsonEncode(_wrapFields(data)),
    );
  }

  Future<void> updateDocumentPath(String path, Map<String, dynamic> data) async {
    final idToken = await _auth.getIdToken();
    await http.patch(
      Uri.parse('$_baseUrl/$path'),
      headers: _headers(idToken),
      body: jsonEncode(_wrapFields(data)),
    );
  }

  Future<void> incrementReligionPoints(String religionId, int points) async {
    await _increment('religions', religionId, points);
  }

  Future<void> incrementOrganizationPoints(String organizationId, int points) async {
    await _increment('organizations', organizationId, points);
  }
}
