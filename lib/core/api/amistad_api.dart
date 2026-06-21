import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class AmistadApi {
  final ApiClient _client;

  AmistadApi(this._client);

  Future<ApiResponse> getMisAmigos() {
    return _client.get(ApiConstants.misAmigos);
  }

  Future<ApiResponse> getSolicitudesPendientes() {
    return _client.get(ApiConstants.solicitudesAmistad);
  }

  Future<ApiResponse> solicitarAmistad(int usuarioId) {
    return _client.post(
      ApiConstants.solicitarAmistad,
      body: {'usuario_id': usuarioId},
    );
  }

  Future<ApiResponse> aceptarSolicitud(int amistadId) {
    return _client.post(ApiConstants.aceptarAmistad(amistadId));
  }

  Future<ApiResponse> rechazarSolicitud(int amistadId) {
    return _client.post(ApiConstants.rechazarAmistad(amistadId));
  }

  Future<ApiResponse> getFans() {
    return _client.get(ApiConstants.fansUsuarios);
  }
}
