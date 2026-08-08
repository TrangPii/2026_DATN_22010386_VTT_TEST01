import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();

  static Future<Map<String, String>> _headers({
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    bool authenticated = false,
  }) async {
    return http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(authenticated: authenticated),
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    return http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? {}),
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    return http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? {}),
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    return http.patch(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? {}),
    );
  }
}
