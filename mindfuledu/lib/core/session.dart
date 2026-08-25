import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';

/// Holds the authenticated user's session (token + profile) and exposes
/// auth actions used across the app.
class Session extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String? token;
  Map<String, dynamic>? user;
  bool isLoading = true;

  String? get role => user?['role'] as String?;
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
  bool get isAuthenticated => token != null && user != null;

  Future<void> bootstrap() async {
    String? storedToken;
    try {
      storedToken = await _storage.read(key: 'token');
    } catch (_) {
      storedToken = null;
    }

    if (storedToken != null) {
      token = storedToken;
      ApiClient.instance.setToken(storedToken);
      try {
        final response = await ApiClient.instance.get('/me');
        user =
            (response.data as Map<String, dynamic>)['user']
                as Map<String, dynamic>;
      } catch (_) {
        await logout();
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await ApiClient.instance.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    await _persist(response.data as Map<String, dynamic>);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? school,
  }) async {
    final response = await ApiClient.instance.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'school': school,
      },
    );
    await _persist(response.data as Map<String, dynamic>);
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    token = data['token'] as String;
    user = data['user'] as Map<String, dynamic>;
    ApiClient.instance.setToken(token);
    await _storage.write(key: 'token', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/logout');
    } catch (_) {
      // ignore network errors on logout
    }
    token = null;
    user = null;
    ApiClient.instance.setToken(null);
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}
