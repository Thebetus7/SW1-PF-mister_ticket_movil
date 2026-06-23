import '../models/zona_model.dart';
import '../models/compra_response_model.dart';
import '../models/mis_ticket_model.dart';
import '../services/compra_service.dart';

class CompraRepository {
  final CompraService _compraService = CompraService();

  Future<List<ZonaModel>> getZonasEvento(int eventoId) async {
    return _compraService.getZonasEvento(eventoId);
  }

  Future<CompraResult> realizarCompra({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String metodoPago,
    String? paymentMethodId,
    String? urlRetorno,
  }) async {
    return _compraService.realizarCompra(
      eventoId: eventoId,
      zonaId: zonaId,
      cantidad: cantidad,
      metodoPago: metodoPago,
      paymentMethodId: paymentMethodId,
      urlRetorno: urlRetorno,
    );
  }

  Future<List<MisTicketModel>> getMisTickets(
      {String filtro = 'comprados'}) async {
    return _compraService.getMisTickets(filtro: filtro);
  }

  Future<void> transferirTicket(int ticketId, int destinatarioId) async {
    await _compraService.transferirTicket(ticketId, destinatarioId);
  }
}
