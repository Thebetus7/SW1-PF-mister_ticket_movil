import '../models/zona_model.dart';
import '../models/compra_response_model.dart';
import '../models/mis_ticket_model.dart';
import '../services/compra_service.dart';

class CompraRepository {
  final CompraService _compraService = CompraService();

  Future<List<ZonaModel>> getZonasEvento(int eventoId) async {
    return await _compraService.getZonasEvento(eventoId);
  }

  Future<CompraResponseModel> realizarCompra({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String paymentMethodId,
  }) async {
    return await _compraService.realizarCompra(
      eventoId: eventoId,
      zonaId: zonaId,
      cantidad: cantidad,
      paymentMethodId: paymentMethodId,
    );
  }

  Future<List<MisTicketModel>> getMisTickets() async {
    return await _compraService.getMisTickets();
  }
}
