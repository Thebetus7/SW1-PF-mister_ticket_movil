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
  CompraResponseModel? _compraResponse;
  List<MisTicketModel> _misTickets = [];

  List<ZonaModel> get zonas => _zonas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CompraResponseModel? get compraResponse => _compraResponse;
  List<MisTicketModel> get misTickets => _misTickets;

  Future<void> loadZonas(int eventoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _zonas = await _compraRepository.getZonasEvento(eventoId);
    } catch (e) {
      _error = e.toString();
      _zonas = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> comprar({
    required int eventoId,
    required int zonaId,
    required int cantidad,
    required String paymentMethodId,
  }) async {
    _isLoading = true;
    _error = null;
    _compraResponse = null;
    notifyListeners();

    try {
      _compraResponse = await _compraRepository.realizarCompra(
        eventoId: eventoId,
        zonaId: zonaId,
        cantidad: cantidad,
        paymentMethodId: paymentMethodId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Extraer mensaje limpio del error si es posible
      final errorStr = e.toString();
      if (errorStr.contains('Exception: ')) {
        _error = errorStr.split('Exception: ').last;
      } else {
        _error = errorStr;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMisTickets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _misTickets = await _compraRepository.getMisTickets();
    } catch (e) {
      _error = e.toString();
      _misTickets = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
