import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitializing = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  Future<bool> restoreSession() async {
    _isInitializing = true;
    notifyListeners();

    final hasSession = await _authRepository.hasStoredSession();
    if (!hasSession) {
      _isAuthenticated = false;
      _isInitializing = false;
      notifyListeners();
      return false;
    }

    _isAuthenticated = await _authRepository.restoreSession();
    _isInitializing = false;
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    _isAuthenticated = await _authRepository.login(username, password);

    _isLoading = false;
    notifyListeners();

    return _isAuthenticated;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
