import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Base URL of the MindfulEdu Laravel API.
///
/// - iOS simulator / physical device on same Wi-Fi as the docker host: use the
///   machine's LAN IP or the `mindfulledu.test` hostname (if resolvable).
/// - Android emulator: use `https://10.0.2.2` to reach the host machine.
/// - Android physical device: use the machine's LAN IP.
/// - Android emulator: use `https://10.0.2.2/api` to reach the host machine.
/// - macOS desktop: use `https://127.0.0.1/api`.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://192.168.1.16/api',
);

const _kBundledLanBaseUrl = 'https://192.168.1.16/api';

const String kApiFallbackUrls = String.fromEnvironment(
  'API_FALLBACK_URLS',
  defaultValue:
      'https://192.168.1.16/api,https://10.0.2.2/api,https://127.0.0.1/api',
);

const _kConnectTimeout = Duration(seconds: 2);
const _kTimeout = Duration(seconds: 10);

/// A decoded JSON API response.
class ApiResponse {
  ApiResponse(this.statusCode, this.data);

  final int statusCode;
  final dynamic data;
}

/// Small `HttpClient`-based API client (no third-party HTTP package needed).
class ApiClient {
  ApiClient._internal() {
    _client = HttpClient()
      ..connectionTimeout = _kConnectTimeout
      ..badCertificateCallback = (cert, host, port) =>
          _isLocalDevelopmentHost(host);
  }

  static final ApiClient instance = ApiClient._internal();

  late final HttpClient _client;

  String? _token;
  String _activeBaseUrl = _preferredBaseUrl();

  String? get token => _token;

  void setToken(String? token) => _token = token;

  Future<ApiResponse> get(String path, {Map<String, dynamic>? query}) {
    return _send('GET', path, query: query);
  }

  Future<ApiResponse> post(String path, {Object? data}) {
    return _send('POST', path, body: data);
  }

  Future<ApiResponse> put(String path, {Object? data}) {
    return _send('PUT', path, body: data);
  }

  Future<ApiResponse> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    ApiException? networkError;

    for (final baseUrl in _candidateBaseUrls()) {
      try {
        final response = await _sendOnce(
          method,
          baseUrl,
          path,
          query: query,
          body: body,
        );
        _activeBaseUrl = baseUrl;

        return response;
      } on TimeoutException {
        networkError = ApiException('Waktu koneksi habis, coba lagi');
      } on SocketException {
        networkError = ApiException('Tidak dapat terhubung ke server');
      } on IOException {
        networkError = ApiException('Tidak dapat terhubung ke server');
      } on FormatException {
        throw ApiException('Respons server tidak valid');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException('Terjadi kesalahan: $e');
      }
    }

    throw networkError ?? ApiException('Tidak dapat terhubung ke server');
  }

  Future<ApiResponse> _sendOnce(
    String method,
    String baseUrl,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null) {
      uri = uri.replace(
        queryParameters: query.map((key, value) => MapEntry(key, '$value')),
      );
    }

    final request = await _client.openUrl(method, uri).timeout(_kTimeout);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (_token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_token');
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final response = await request.close().timeout(_kTimeout);
    final raw = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_kTimeout);
    final decoded = raw.isEmpty ? null : jsonDecode(raw);

    if (response.statusCode >= 400) {
      throw _mapError(decoded);
    }

    return ApiResponse(response.statusCode, decoded);
  }

  List<String> _candidateBaseUrls() {
    final urls = <String>[];

    void add(String value) {
      final clean = value.trim();
      if (clean.isNotEmpty && !urls.contains(clean)) {
        urls.add(clean);
      }
    }

    add(_activeBaseUrl);
    add(kApiBaseUrl);
    for (final fallback in kApiFallbackUrls.split(',')) {
      add(fallback);
    }

    return urls;
  }

  static String _preferredBaseUrl() {
    if (kApiBaseUrl != _kBundledLanBaseUrl || kIsWeb) {
      return kApiBaseUrl;
    }

    return kApiBaseUrl;
  }

  static bool _isLocalDevelopmentHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host);
  }

  ApiException _mapError(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 'Terjadi kesalahan';
      final errors = data['errors'] as Map<String, dynamic>?;
      return ApiException(message, errors: errors);
    }
    return ApiException('Terjadi kesalahan');
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.errors});

  final String message;
  final Map<String, dynamic>? errors;

  @override
  String toString() => message;
}
