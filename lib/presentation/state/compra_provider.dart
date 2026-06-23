import 'package:flutter/material.dart';
import '../../data/models/zona_model.dart';
import '../../data/models/compra_response_model.dart';
import '../../data/models/mis_ticket_model.dart';
import '../../data/repositories/compra_repository.dart';

class CompraProvider extends ChangeNotifier {
  final CompraRepository _compraRepository = CompraRepository();

  List<ZonaModel> _zonas = [];
  bool _isLoading = false;
  String? _error;

  // Ultimo resultado de compra. Puede ser CompraStripeResult o CompraLibelulaResult.
  CompraResult? _compraResult;

  List<MisTicketModel> _misTickets = [];
  String _filtroTickets = 'comprados';
  bool _isLoadingTickets = false;
  int _ticketsRequestSeq = 0;

  // Getters
  List<ZonaModel> get zonas => _zonas;
  bool get isLoading => _isLoading;
  bool get isLoadingTickets => _isLoadingTickets;
  String? get error => _error;
  CompraResult? get compraResult => _compraResult;
  List<MisTicketModel> get misTickets => _misTickets;
  String get filtroTickets => _filtroTickets;

  /// Acceso directo al CompraResponseModel cuando el flujo fue Stripe.
  CompraResponseModel? get compraResponse {
    final result = _compraResult;
    return result is CompraStripeResult ? result.compraResponse : null;
  }

  Future<void> loadZonas(int eventoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _zonas = await _compraRepository.getZonasEvento(eventoId);
    } catch (e) {
      _error = _parseError(e);
      _zonas = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Procesa la compra con el metodo de pago indicado.
  ///
  /// Retorna un [CompraResult] en exito, o `null` si hubo error
  /// (el mensaje queda en [error]).
  ///
  /// - [metodoPago]: `'stripe'` o `'libelula'`
  /// - [paymentMethodId]: requerido solo para Stripe.
  /// - [urlRetorno]: deep-link al que Libelula redirige tras el pago.
  Future<CompraResult?> comprar({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String metodoPago,
    String? paymentMethodId,
    String urlRetorno = 'miapp://pago-completado',
  }) async {
    _isLoading = true;
    _error = null;
    _compraResult = null;
    notifyListeners();

    try {
      _compraResult = await _compraRepository.realizarCompra(
        eventoId: eventoId,
        zonaId: zonaId,
        cantidad: cantidad,
        metodoPago: metodoPago,
        paymentMethodId: paymentMethodId,
        urlRetorno: urlRetorno,
      );
      _isLoading = false;
      notifyListeners();
      return _compraResult;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMisTickets({String? filtro}) async {
    final filtroSolicitado = filtro ?? _filtroTickets;
    final cambioFiltro = filtro != null && filtro != _filtroTickets;

    if (filtro != null) _filtroTickets = filtro;

    final requestId = ++_ticketsRequestSeq;

    if (cambioFiltro) _misTickets = [];

    _isLoadingTickets = true;
    _error = null;
    notifyListeners();

    try {
      final tickets =
          await _compraRepository.getMisTickets(filtro: filtroSolicitado);
      if (requestId != _ticketsRequestSeq) return;
      _misTickets = tickets;
      _error = null;
    } catch (e) {
      if (requestId != _ticketsRequestSeq) return;
      _error = _parseError(e);
      _misTickets = [];
    }

    if (requestId == _ticketsRequestSeq) {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  String _parseError(Object e) {
    final raw = e.toString();
    return raw.contains('Exception: ') ? raw.split('Exception: ').last : raw;
  }
}
