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
      return (response.data as List)
          .map((json) => ZonaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Realiza la compra enrutando según [metodoPago]:
  ///
  /// - `'stripe'`   → requiere [paymentMethodId]; devuelve [CompraStripeResult]
  ///                  con la factura y los tickets activos.
  /// - `'libelula'` → [paymentMethodId] se ignora; devuelve [CompraLibelulaResult]
  ///                  con la URL del WebView donde el usuario completa el pago.
  Future<CompraResult> realizarCompra({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String metodoPago,
    String? paymentMethodId,
    String? urlRetorno,
  }) async {
    final body = <String, dynamic>{
      'evento_id': eventoId,
      'zona_id': zonaId,
      'cantidad': cantidad,
      'metodo_pago': metodoPago,
    };

    if (metodoPago == 'stripe' &&
        paymentMethodId != null &&
        paymentMethodId.isNotEmpty) {
      body['payment_method_id'] = paymentMethodId;
    }

    if (metodoPago == 'libelula') {
      body['url_retorno'] = urlRetorno ?? '';
    }

    final response = await _compraApi.realizarCompra(body);

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Formato de respuesta de compra invalido.');
    }

    final data = response.data as Map<String, dynamic>;

    if (metodoPago == 'libelula') {
      final url = data['url_pasarela_pagos'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception(
            'La pasarela no devolvio una URL de pago. Intenta de nuevo.');
      }
      return CompraLibelulaResult(url);
    } else {
      return CompraStripeResult(CompraResponseModel.fromJson(data));
    }
  }

  Future<List<MisTicketModel>> getMisTickets(
      {String filtro = 'comprados'}) async {
    final response = await _compraApi.getMisTickets(filtro: filtro);
    if (response.data is List) {
      return (response.data as List)
          .map((json) => MisTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> transferirTicket(int ticketId, int destinatarioId) async {
    await _compraApi.transferirTicket(ticketId, destinatarioId);
  }
}
