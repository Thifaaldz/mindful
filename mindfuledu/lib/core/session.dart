import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'api_client.dart';

/// Holds the authenticated user's session (token + profile) and exposes
/// auth actions used across the app.
class Session extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  static const _tokenKey = 'token';
  static const _quickLoginEnabledKey = 'quick_login_enabled';
  static const _savedAccountKey = 'saved_account';

  String? token;
  Map<String, dynamic>? user;
  Map<String, dynamic>? savedAccount;
  bool isLoading = true;
  bool quickLoginAvailable = false;

  String? get role => user?['role'] as String?;
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
  bool get isParent => role == 'parent';
  bool get isAuthenticated => token != null && user != null;
  bool get needsProfileCompletion =>
      isAuthenticated && user?['profile_completed'] != true;

  Future<void> bootstrap() async {
    try {
      await _bootstrapSession().timeout(const Duration(seconds: 8));
    } catch (_) {
      token = null;
      user = null;
      savedAccount = null;
      quickLoginAvailable = false;
      ApiClient.instance.setToken(null);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _bootstrapSession() async {
    String? storedToken;
    String? quickLoginEnabled;
    try {
      storedToken = await _storage.read(key: _tokenKey);
      quickLoginEnabled = await _storage.read(key: _quickLoginEnabledKey);
    } catch (_) {
      storedToken = null;
      quickLoginEnabled = null;
    }

    if (storedToken != null) {
      if (quickLoginEnabled == 'true') {
        await _loadSavedAccount();
        quickLoginAvailable = savedAccount != null;
      } else {
        await _restoreStoredToken(storedToken, clearOnFailure: true);
      }
    }
  }

  Future<void> login(
    String email,
    String password, {
    required String role,
    bool rememberDevice = false,
  }) async {
    final response = await ApiClient.instance.post(
      '/login',
      data: {'email': email, 'password': password, 'role': role},
    );
    await _persist(
      response.data as Map<String, dynamic>,
      rememberDevice: rememberDevice,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    String? name,
    String? role,
    String? school,
    String? className,
    String? studentVerificationCode,
    bool rememberDevice = false,
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
        'class_name': className,
        'student_verification_code': studentVerificationCode,
      },
    );
    await _persist(
      response.data as Map<String, dynamic>,
      rememberDevice: rememberDevice,
    );
  }

  Future<void> loginWithGoogleIdToken(
    String idToken, {
    required String role,
    bool rememberDevice = false,
  }) async {
    final response = await ApiClient.instance.post(
      '/auth/google',
      data: {'id_token': idToken, 'role': role},
    );
    await _persist(
      response.data as Map<String, dynamic>,
      rememberDevice: rememberDevice,
    );
  }

  Future<void> completeProfile({
    required String name,
    required String role,
    String? school,
    String? className,
    String? studentVerificationCode,
  }) async {
    final response = await ApiClient.instance.put(
      '/me/profile',
      data: {
        'name': name,
        'role': role,
        'school': school,
        'class_name': className,
        'student_verification_code': studentVerificationCode,
      },
    );
    user =
        (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
    await _saveAccountMetadata();
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String school,
    String? className,
  }) async {
    final currentRole = role;
    if (currentRole == null) {
      throw ApiException('Role akun tidak ditemukan');
    }

    final response = await ApiClient.instance.put(
      '/me/profile',
      data: {
        'name': name,
        'role': currentRole,
        'school': school,
        'class_name': className,
      },
    );
    user =
        (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
    await _saveAccountMetadata();
    notifyListeners();
  }

  Future<void> updateAvatar(String imagePath) async {
    final response = await ApiClient.instance.postMultipart(
      '/me/avatar',
      fields: const {},
      fileField: 'avatar',
      filePath: imagePath,
    );
    user =
        (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>;
    await _saveAccountMetadata();
    notifyListeners();
  }

  Future<void> quickLogin({required String role}) async {
    final savedRole = savedAccount?['role'] as String?;
    if (savedRole != null && savedRole != role) {
      throw ApiException('Akun tersimpan bukan untuk akses ini');
    }

    final supported =
        await _localAuth.isDeviceSupported() ||
        await _localAuth.canCheckBiometrics;

    if (!supported) {
      throw ApiException('PIN atau biometrik belum aktif di perangkat ini');
    }

    final ok = await _localAuth.authenticate(
      localizedReason: 'Gunakan PIN atau biometrik untuk masuk ke MindfulEdu',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false,
      ),
    );

    if (!ok) {
      throw ApiException('Autentikasi cepat dibatalkan');
    }

    final storedToken = await _storage.read(key: _tokenKey);

    if (storedToken == null) {
      await _clearSavedSession();
      throw ApiException('Akun tersimpan tidak ditemukan, silakan login ulang');
    }

    await _restoreStoredToken(storedToken, clearOnFailure: true);

    if (this.role != role) {
      await _clearSavedSession();
      token = null;
      user = null;
      ApiClient.instance.setToken(null);
      throw ApiException('Akun tersimpan bukan untuk akses ini');
    }

    notifyListeners();
  }

  Future<void> _persist(
    Map<String, dynamic> data, {
    required bool rememberDevice,
  }) async {
    token = data['token'] as String;
    user = data['user'] as Map<String, dynamic>;
    ApiClient.instance.setToken(token);

    if (rememberDevice) {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _quickLoginEnabledKey, value: 'true');
      await _saveAccountMetadata();
      quickLoginAvailable = true;
    } else {
      await _clearSavedSession(keepCurrentSession: true);
    }

    notifyListeners();
  }

  Future<void> logout({bool remote = true}) async {
    if (remote) {
      try {
        await ApiClient.instance.post('/logout');
      } catch (_) {
        // ignore network errors on logout
      }
    }
    token = null;
    user = null;
    ApiClient.instance.setToken(null);
    await _clearSavedSession();
    notifyListeners();
  }

  Future<void> _restoreStoredToken(
    String storedToken, {
    required bool clearOnFailure,
  }) async {
    token = storedToken;
    ApiClient.instance.setToken(storedToken);
    try {
      final response = await ApiClient.instance.get('/me');
      user =
          (response.data as Map<String, dynamic>)['user']
              as Map<String, dynamic>;
    } catch (_) {
      token = null;
      user = null;
      ApiClient.instance.setToken(null);
      if (clearOnFailure) {
        await _clearSavedSession();
      }
    }
  }

  Future<void> _loadSavedAccount() async {
    try {
      final raw = await _storage.read(key: _savedAccountKey);
      savedAccount = raw == null
          ? null
          : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      savedAccount = null;
    }
  }

  Future<void> _saveAccountMetadata() async {
    if (user == null) return;

    savedAccount = {
      'name': user?['name'],
      'email': user?['email'],
      'avatar_url': user?['avatar_url'],
      'role': user?['role'],
    };

    await _storage.write(
      key: _savedAccountKey,
      value: jsonEncode(savedAccount),
    );
  }

  Future<void> _clearSavedSession({bool keepCurrentSession = false}) async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _quickLoginEnabledKey);
    await _storage.delete(key: _savedAccountKey);

    if (!keepCurrentSession) {
      savedAccount = null;
      quickLoginAvailable = false;
    }
  }
}
