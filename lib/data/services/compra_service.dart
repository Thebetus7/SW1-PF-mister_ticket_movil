import '../../core/api/compra_api.dart';
import '../../core/network/api_client.dart';
import '../models/zona_model.dart';
import '../models/compra_response_model.dart';
import '../models/mis_ticket_model.dart';

class CompraService {
  final CompraApi _compraApi;

  CompraService() : _compraApi = CompraApi(ApiClient());

  Future<List<ZonaModel>> getZonasEvento(int eventoId) async {
    final response = await _compraApi.getZonasEvento(eventoId);
    if (response.data is List) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ZonaModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<CompraResponseModel> realizarCompra({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String paymentMethodId,
  }) async {
    final body = {
      'evento_id': eventoId,
      'zona_id': zonaId,
      'cantidad': cantidad,
      'payment_method_id': paymentMethodId,
    };
    final response = await _compraApi.realizarCompra(body);
    if (response.data is Map<String, dynamic>) {
      return CompraResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Formato de respuesta de compra inválido.');
    }
  }

  Future<List<MisTicketModel>> getMisTickets() async {
    final response = await _compraApi.getMisTickets();
    if (response.data is List) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MisTicketModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> transferirTicket(int ticketId, int destinatarioId) async {
    final response = await _compraApi.transferirTicket(ticketId, destinatarioId);
    if (response.data is! Map<String, dynamic>) {
      throw Exception('Respuesta de transferencia inválida.');
    }
  }
}
