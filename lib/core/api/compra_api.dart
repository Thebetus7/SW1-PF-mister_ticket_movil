import '../network/api_client.dart';
import '../network/api_response.dart';
import '../constants/api_constants.dart';

class CompraApi {
  final ApiClient _client;

  CompraApi(this._client);

  Future<ApiResponse> getZonasEvento(int eventoId) {
    return _client.get(ApiConstants.zonasEvento(eventoId));
  }

  Future<ApiResponse> realizarCompra(Map<String, dynamic> body) {
    return _client.post(ApiConstants.comprar, body: body);
  }

  Future<ApiResponse> getMisTickets() {
    return _client.get(ApiConstants.misTickets);
  }

  Future<ApiResponse> transferirTicket(int ticketId, int destinatarioId) {
    return _client.post(
      ApiConstants.transferirTicket(ticketId),
      body: {'destinatario_id': destinatarioId},
    );
  }
}
