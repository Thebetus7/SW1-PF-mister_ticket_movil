import '../../core/api/amistad_api.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/amigo_model.dart';
import '../models/amistad_model.dart';
import '../models/fan_usuario_model.dart';

class AmistadService {
  final AmistadApi _amistadApi;

  AmistadService() : _amistadApi = AmistadApi(ApiClient());

  Future<List<AmigoModel>> getMisAmigos() async {
    final response = await _amistadApi.getMisAmigos();
    if (response.data is List) {
      return (response.data as List)
          .map((json) => AmigoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<AmistadModel>> getSolicitudesPendientes() async {
    final response = await _amistadApi.getSolicitudesPendientes();
    if (response.data is List) {
      return (response.data as List)
          .map((json) => AmistadModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> solicitarAmistad(int usuarioId) async {
    await _amistadApi.solicitarAmistad(usuarioId);
  }

  Future<void> aceptarSolicitud(int amistadId) async {
    await _amistadApi.aceptarSolicitud(amistadId);
  }

  Future<void> rechazarSolicitud(int amistadId) async {
    await _amistadApi.rechazarSolicitud(amistadId);
  }

  Future<List<FanUsuarioModel>> getFans() async {
    final response = await _amistadApi.getFans();
    if (response.data is List) {
      return (response.data as List)
          .map((json) => FanUsuarioModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> buscarUsuario(String username) async {
    final client = ApiClient();
    final response = await client.get(
      '${ApiConstants.baseUrl}/usuarios/lista/',
      queryParams: {'search': username},
    );
    if (response.data is List) {
      return (response.data as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
