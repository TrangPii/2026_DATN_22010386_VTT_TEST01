import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

enum AppMode { customer, provider }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;

  AppMode _appMode = AppMode.customer;

  bool _isLoading = false;
  bool _isInitializing = true;

  String? _error;

  User? get user => _user;

  AppMode get appMode => _appMode;

  bool get isCustomerMode => _appMode == AppMode.customer;

  bool get isProviderMode => _appMode == AppMode.provider;

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  Future<void> initialize() async {
    try {
      _user = await _authService.getCurrentUser();

      _appMode = AppMode.customer;

      _error = null;
    } on AuthException catch (e) {
      _user = null;
      _appMode = AppMode.customer;
      _error = e.message;
    } catch (_) {
      _user = null;
      _appMode = AppMode.customer;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);

    try {
      _user = await _authService.login(email: email, password: password);
      _appMode = AppMode.customer;
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

  // Register Provider
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

      _appMode = AppMode.customer;
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

  Future<bool> refreshCurrentUser() async {
    try {
      final refreshedUser = await _authService.getCurrentUser();

      if (refreshedUser == null) {
        _user = null;
        _appMode = AppMode.customer;

        notifyListeners();

        return false;
      }

      _user = refreshedUser;

      // Nếu đang ở Provider mode nhưng tài khoản không còn quyền Provider thì tự quay về  Customer mode.
      if (_appMode == AppMode.provider && !_user!.canUseProviderMode) {
        _appMode = AppMode.customer;
      }

      _error = null;

      notifyListeners();

      return true;
    } on AuthException catch (e) {
      _error = e.message;

      notifyListeners();

      return false;
    } catch (_) {
      _error = 'Không thể cập nhật thông tin tài khoản.';

      notifyListeners();

      return false;
    }
  }

  /// Chuyển sang chế độ Customer.
  void switchToCustomerMode() {
    if (_appMode == AppMode.customer) {
      return;
    }

    _appMode = AppMode.customer;

    notifyListeners();
  }

  // Chuyển sang chế độ Provider. Flutter chỉ cho phép khi backend trả: can_use_provider_mode = true.
  bool switchToProviderMode() {
    final currentUser = _user;

    if (currentUser == null || !currentUser.canUseProviderMode) {
      return false;
    }

    if (_appMode == AppMode.provider) {
      return true;
    }

    _appMode = AppMode.provider;

    notifyListeners();

    return true;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _user = null;
      _appMode = AppMode.customer;
      _error = null;

      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }
}
