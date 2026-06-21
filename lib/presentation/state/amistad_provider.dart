import 'package:flutter/material.dart';
import '../../data/models/amigo_model.dart';
import '../../data/models/amistad_model.dart';
import '../../data/models/fan_usuario_model.dart';
import '../../data/repositories/amistad_repository.dart';
import '../../data/repositories/compra_repository.dart';

class AmistadProvider extends ChangeNotifier {
  final AmistadRepository _amistadRepository = AmistadRepository();
  final CompraRepository _compraRepository = CompraRepository();

  List<AmigoModel> _amigos = [];
  List<FanUsuarioModel> _fans = [];
  List<AmistadModel> _solicitudes = [];
  bool _isLoading = false;
  bool _isLoadingFans = false;
  bool _isTransferring = false;
  String? _error;

  List<AmigoModel> get amigos => _amigos;
  List<FanUsuarioModel> get fans => _fans;
  List<AmistadModel> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  bool get isLoadingFans => _isLoadingFans;
  bool get isTransferring => _isTransferring;
  String? get error => _error;

  Future<void> loadFans() async {
    _isLoadingFans = true;
    _error = null;
    notifyListeners();

    try {
      _fans = await _amistadRepository.getFans();
    } catch (e) {
      _error = _extractError(e);
      _fans = [];
    }

    _isLoadingFans = false;
    notifyListeners();
  }

  Future<void> loadAmigos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _amigos = await _amistadRepository.getMisAmigos();
    } catch (e) {
      _error = _extractError(e);
      _amigos = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSolicitudes() async {
    try {
      _solicitudes = await _amistadRepository.getSolicitudesPendientes();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> solicitarAmistad(int usuarioId) async {
    _error = null;
    notifyListeners();

    try {
      await _amistadRepository.solicitarAmistad(usuarioId);
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> aceptarSolicitud(int amistadId) async {
    try {
      await _amistadRepository.aceptarSolicitud(amistadId);
      await loadSolicitudes();
      await loadAmigos();
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> rechazarSolicitud(int amistadId) async {
    try {
      await _amistadRepository.rechazarSolicitud(amistadId);
      await loadSolicitudes();
      return true;
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> buscarUsuario(String username) async {
    try {
      return await _amistadRepository.buscarUsuario(username);
    } catch (e) {
      _error = _extractError(e);
      notifyListeners();
      return [];
    }
  }

  Future<bool> transferirTicket(int ticketId, int destinatarioId) async {
    _isTransferring = true;
    _error = null;
    notifyListeners();

    try {
      await _compraRepository.transferirTicket(ticketId, destinatarioId);
      _isTransferring = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractError(e);
      _isTransferring = false;
      notifyListeners();
      return false;
    }
  }

  String _extractError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('Exception: ')) {
      return errorStr.split('Exception: ').last;
    }
    return errorStr;
  }
}
