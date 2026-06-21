import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

/// API modular de autenticación.
/// Define TODOS los endpoints relacionados con auth.
/// NO parsea modelos — eso es responsabilidad del Service.
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<ApiResponse> login(String username, String password) {
    return _client.post(ApiConstants.login, body: {
      'username': username,
      'password': password,
    });
  }

  Future<ApiResponse> getProfile() {
    return _client.get(ApiConstants.profile);
  }

  Future<ApiResponse> refreshToken(String refreshToken) {
    return _client.post(ApiConstants.tokenRefresh, body: {
      'refresh': refreshToken,
    });
  }
}
