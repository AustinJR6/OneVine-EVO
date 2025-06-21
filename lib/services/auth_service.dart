import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_config.dart';

class AuthUser {
  final String uid;
  final String email;
  final String idToken;
  final String refreshToken;

  AuthUser({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.refreshToken,
  });
}

class AuthService {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  Stream<AuthUser?> get authStateChanges => _controller.stream;
  AuthUser? get currentUser => _currentUser;

  Future<String?> getIdToken() async => _currentUser?.idToken;

  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) async {
    final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final user = AuthUser(
        uid: data['localId'] as String,
        email: data['email'] as String,
        idToken: data['idToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      _currentUser = user;
      _controller.add(user);
      return user;
    } else {
      throw Exception(jsonDecode(res.body)['error']['message']);
    }
  }

  Future<AuthUser?> registerWithEmailAndPassword(String email, String password) async {
    final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$firebaseApiKey');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final user = AuthUser(
        uid: data['localId'] as String,
        email: data['email'] as String,
        idToken: data['idToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      _currentUser = user;
      _controller.add(user);
      return user;
    } else {
      throw Exception(jsonDecode(res.body)['error']['message']);
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
