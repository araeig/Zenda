import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../widgets/zenda_toast.dart';
import 'locale_service.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) return 'https://localhost:7251';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'http://10.0.2.2:5132';
    return 'https://localhost:7251';
  }

  static const Duration _timeout = Duration(seconds: 15);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': currentLocale.value.languageCode,
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final headers = await _headers();
    return _send(
      'GET',
      path,
      () => http.get(Uri.parse('$baseUrl$path'), headers: headers),
    );
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
    Duration? timeout,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    return _send(
      'POST',
      path,
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      ),
      timeout: timeout,
    );
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return _send(
      'PUT',
      path,
      () => http.put(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> delete(String path) async {
    final headers = await _headers();
    return _send(
      'DELETE',
      path,
      () => http.delete(Uri.parse('$baseUrl$path'), headers: headers),
    );
  }

  Future<dynamic> upload(
    String path,
    String field,
    List<int> bytes,
    String filename, {
    Map<String, String>? fields,
  }) async {
    final token = await _getToken();
    return _send('POST', path, () async {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      request.headers['Accept-Language'] = currentLocale.value.languageCode;
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (fields != null) request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes(field, bytes, filename: filename),
      );
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }, timeout: const Duration(seconds: 60));
  }

  Future<dynamic> _send(
    String method,
    String path,
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    http.Response response;
    try {
      response = await request().timeout(timeout ?? _timeout);
    } catch (e) {
      print('$method $path error: $e');
      final t = lookupAppLocalizations(currentLocale.value);
      showZendaToastGlobal(
        t.noConnectionTitle,
        subtitle: t.noConnectionSubtitle,
        priority: true,
      );
      return null;
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      print('$method $path decode error: $e');
      return null;
    }
  }
}
