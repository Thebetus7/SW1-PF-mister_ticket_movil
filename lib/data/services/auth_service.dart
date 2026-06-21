import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/auth_api.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';

/// Service de autenticación.
/// Usa AuthApi (módulo API) — NUNCA ApiClient directamente.
/// Se encarga del parseo de respuesta y la lógica de negocio (guardar tokens).
class AuthService {
  final AuthApi _authApi;

  AuthService() : _authApi = AuthApi(ApiClient());

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _authApi.login(username, password);
    final data = response.data as Map<String, dynamic>;

    await _saveTokens(data['access'] as String, data['refresh'] as String);
    return data;
  }

  Future<bool> hasStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  /// Valida la sesión guardada. Intenta refresh si el access token expiró.
  Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null) return false;

    try {
      await _authApi.getProfile();
      return true;
    } on UnauthorizedException {
      return await refreshAccessToken();
    } catch (_) {
      return false;
    }
  }

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await _authApi.refreshToken(refreshToken);
      final data = response.data as Map<String, dynamic>;
      await prefs.setString('access_token', data['access'] as String);
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}
