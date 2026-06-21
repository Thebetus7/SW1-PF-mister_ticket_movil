import '../../core/api/notificacion_api.dart';
import '../../core/network/api_client.dart';
import '../models/notificacion.dart';

class NotificacionService {
  final NotificacionApi _notificacionApi;

  NotificacionService() : _notificacionApi = NotificacionApi(ApiClient());

  /// Obtiene la lista de notificaciones del usuario actual
  Future<List<NotificacionModel>> getNotificaciones() async {
    final response = await _notificacionApi.getNotificaciones();
    final List<dynamic> data = response.data as List? ?? [];
    return data.map((json) => NotificacionModel.fromJson(json)).toList();
  }

  /// Marca una notificación como leída
  Future<bool> marcarLeida(int id) async {
    final response = await _notificacionApi.marcarLeida(id);
    return response.statusCode == 200;
  }

  /// Marca todas las notificaciones como leídas
  Future<bool> marcarTodasLeidas() async {
    final response = await _notificacionApi.marcarTodasLeidas();
    return response.statusCode == 200;
  }

  /// Elimina una notificación físicamente
  Future<bool> eliminarNotificacion(int id) async {
    final response = await _notificacionApi.eliminarNotificacion(id);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  /// Registra el token FCM del dispositivo actual
  Future<bool> registrarFCMToken(String token) async {
    final response = await _notificacionApi.registrarFCMToken(token);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Alterna el seguimiento de un promotor
  Future<bool> seguirPromotor(int promotorId) async {
    final response = await _notificacionApi.seguirPromotor(promotorId);
    if (response.data is Map) {
      return response.data['siguiendo'] as bool? ?? false;
    }
    return false;
  }

  /// Obtiene los IDs de los promotores seguidos
  Future<List<int>> getPromotoresSeguidos() async {
    final response = await _notificacionApi.getPromotoresSeguidos();
    if (response.data is Map) {
      final List<dynamic> list = response.data['promotores_seguidos'] as List? ?? [];
      return List<int>.from(list);
    }
    return [];
  }

  /// Obtiene el detalle de un evento por ID
  Future<Map<String, dynamic>> getEventoDetalle(int id) async {
    final response = await _notificacionApi.getEventoDetalle(id);
    return response.data as Map<String, dynamic>;
  }
}
