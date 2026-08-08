import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  Future<User> login({required String email, required String password}) async {
    final response = await ApiClient.post(
      ApiConstants.login,
      body: {
        'email': email.trim(),
        'password': password,
        'device_name': 'Flutter Android',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw AuthException(_extractMessage(data));
    }

    final token = data['data']['token'] as String;

    await TokenStorage.saveToken(token);

    return User.fromJson(data['data']['user'] as Map<String, dynamic>);
  }

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.register,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'password_confirmation': password,
        'device_name': 'Flutter Android',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw AuthException(_extractMessage(data));
    }

    final token = data['data']['token'] as String;

    await TokenStorage.saveToken(token);

    return User.fromJson(data['data']['user'] as Map<String, dynamic>);
  }

  Future<User?> getCurrentUser() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      return null;
    }

    final response = await ApiClient.get(ApiConstants.me, authenticated: true);

    if (response.statusCode == 401) {
      await TokenStorage.deleteToken();
      return null;
    }

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    return User.fromJson(data['data']['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await ApiClient.post(ApiConstants.logout, authenticated: true);
    } finally {
      await TokenStorage.deleteToken();
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
