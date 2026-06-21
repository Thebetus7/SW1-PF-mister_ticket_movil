import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

/// API modular para el consumo de notificaciones, registro de FCM y seguimiento de promotores.
class NotificacionApi {
  final ApiClient _client;

  NotificacionApi(this._client);

  /// GET /api/usuarios/notificaciones/ — Obtener mi buzón de alertas
  Future<ApiResponse> getNotificaciones() {
    return _client.get(ApiConstants.notificaciones);
  }

  /// PATCH /api/usuarios/notificaciones/{id}/leer/ — Marcar como leída
  Future<ApiResponse> marcarLeida(int id) {
    return _client.patch('${ApiConstants.notificaciones}$id/leer/');
  }

  /// POST /api/usuarios/notificaciones/leer-todas/ — Marcar todas como leídas
  Future<ApiResponse> marcarTodasLeidas() {
    return _client.post('${ApiConstants.notificaciones}leer-todas/');
  }

  /// DELETE /api/usuarios/notificaciones/{id}/ — Borrar físicamente una notificación (deslizar)
  Future<ApiResponse> eliminarNotificacion(int id) {
    return _client.delete('${ApiConstants.notificaciones}$id/');
  }

  /// POST /api/usuarios/dispositivos/registrar/ — Registrar el token FCM del dispositivo actual
  Future<ApiResponse> registrarFCMToken(String token) {
    return _client.post(
      ApiConstants.registrarDispositivo,
      body: {'fcm_token': token},
    );
  }

  /// POST /api/usuarios/promotores/{id}/seguir/ — Alternar el seguimiento (seguir / dejar de seguir)
  Future<ApiResponse> seguirPromotor(int promotorId) {
    return _client.post('${ApiConstants.promotores}$promotorId/seguir/');
  }

  /// GET /api/usuarios/promotores/siguiendo/ — Listar los IDs de promotores que sigo
  Future<ApiResponse> getPromotoresSeguidos() {
    return _client.get('${ApiConstants.promotores}siguiendo/');
  }

  /// GET /api/eventos/eventos/{id}/ — Obtener detalles de un evento
  Future<ApiResponse> getEventoDetalle(int id) {
    return _client.get('${ApiConstants.baseUrl}/eventos/eventos/$id/');
  }
}
