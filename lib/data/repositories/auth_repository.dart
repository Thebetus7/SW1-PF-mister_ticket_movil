import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> login(String username, String password) async {
    try {
      await _authService.login(username, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasStoredSession() => _authService.hasStoredSession();

  Future<bool> restoreSession() => _authService.validateSession();

  Future<void> logout() async {
    await _authService.logout();
  }
}
