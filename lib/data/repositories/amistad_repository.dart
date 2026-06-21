import '../models/amigo_model.dart';
import '../models/amistad_model.dart';
import '../models/fan_usuario_model.dart';
import '../services/amistad_service.dart';

class AmistadRepository {
  final AmistadService _amistadService = AmistadService();

  Future<List<AmigoModel>> getMisAmigos() async {
    return await _amistadService.getMisAmigos();
  }

  Future<List<AmistadModel>> getSolicitudesPendientes() async {
    return await _amistadService.getSolicitudesPendientes();
  }

  Future<void> solicitarAmistad(int usuarioId) async {
    return await _amistadService.solicitarAmistad(usuarioId);
  }

  Future<void> aceptarSolicitud(int amistadId) async {
    return await _amistadService.aceptarSolicitud(amistadId);
  }

  Future<void> rechazarSolicitud(int amistadId) async {
    return await _amistadService.rechazarSolicitud(amistadId);
  }

  Future<List<FanUsuarioModel>> getFans() async {
    return await _amistadService.getFans();
  }

  Future<List<Map<String, dynamic>>> buscarUsuario(String username) async {
    return await _amistadService.buscarUsuario(username);
  }
}
