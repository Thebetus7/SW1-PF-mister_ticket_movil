import '../models/notificacion.dart';
import '../services/notificacion_service.dart';

class NotificacionRepository {
  final NotificacionService _service = NotificacionService();

  Future<List<NotificacionModel>> getNotificaciones() async {
    try {
      return await _service.getNotificaciones();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> marcarLeida(int id) async {
    try {
      return await _service.marcarLeida(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> marcarTodasLeidas() async {
    try {
      return await _service.marcarTodasLeidas();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> eliminarNotificacion(int id) async {
    try {
      return await _service.eliminarNotificacion(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> registrarFCMToken(String token) async {
    try {
      return await _service.registrarFCMToken(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> seguirPromotor(int promotorId) async {
    try {
      return await _service.seguirPromotor(promotorId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> getPromotoresSeguidos() async {
    try {
      return await _service.getPromotoresSeguidos();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEventoDetalle(int id) async {
    try {
      return await _service.getEventoDetalle(id);
    } catch (e) {
      rethrow;
    }
  }
}
