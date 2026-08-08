import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  Future<void> initialize() async {
    try {
      _user = await _authService.getCurrentUser();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);

    try {
      _user = await _authService.login(email: email, password: password);

      _error = null;

      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Không thể kết nối đến máy chủ.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _user = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _error = null;

      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Không thể kết nối đến máy chủ.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
