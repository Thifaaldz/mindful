import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

import 'api_client.dart';

const String kGoogleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '772190179768-lc0qvgp76q531djrnb2n7q93cttm23v9.apps.googleusercontent.com',
);

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: kGoogleServerClientId.isEmpty
        ? null
        : kGoogleServerClientId,
  );

  static Future<String?> signInAndGetIdToken() async {
    final GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' &&
          (e.message?.contains(': 10') ?? false)) {
        throw ApiException(
          'Konfigurasi Google Android belum cocok. Cek Android OAuth client: package com.example.mindfuledu dan SHA-1 debug harus terdaftar di project Google yang sama.',
        );
      }

      throw ApiException('Login Google gagal: ${e.message ?? e.code}');
    }

    if (account == null) {
      return null;
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw ApiException(
        'Google belum mengirim token. Pastikan GOOGLE_SERVER_CLIENT_ID sudah sesuai.',
      );
    }

    return idToken;
  }

  static Future<void> signOut() => _googleSignIn.signOut();
}
