import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import '../../data/repositories/cancion_repository.dart';
import '../../core/constants/api_constants.dart';

class CancionProvider extends ChangeNotifier {
  final CancionRepository _repository = CancionRepository();

  List<dynamic> _canciones = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get canciones => _canciones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Modifica la URL local de MinIO para que el emulador Android o el dispositivo físico la reconozca.
  String fixLocalhostUrl(String? rawUrl) {
    if (rawUrl == null) return '';
    
    String targetHost = '10.0.2.2'; // Por defecto emulador
    try {
      final uri = Uri.parse(ApiConstants.baseUrl);
      if (uri.host.isNotEmpty) {
        targetHost = uri.host;
      }
    } catch (_) {}

    if (!kIsWeb && (rawUrl.contains('localhost:9000') || rawUrl.contains('127.0.0.1:9000'))) {
      return rawUrl
          .replaceAll('localhost:9000', '$targetHost:9000')
          .replaceAll('127.0.0.1:9000', '$targetHost:9000');
    }
    return rawUrl;
  }

  Future<void> loadCanciones() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _canciones = await _repository.getCanciones();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadCancion({
    required XFile archivo,
    required String nombre,
    required String detalle,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadCancion(
        archivo: archivo,
        nombre: nombre,
        detalle: detalle,
      );
      await loadCanciones(); // Recargar la lista después de subir
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCancion(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCancion(id);
      _canciones.removeWhere((c) => c['id'] == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Alterna el estado de publicación de una canción del artista autenticado (pública/privada).
  /// Realiza la petición al backend y actualiza reactivamente la canción en la lista en memoria.
  Future<bool> togglePublicado(int id, bool actualPublicado) async {
    _errorMessage = null;
    try {
      final nuevoPublicado = !actualPublicado;
      await _repository.updateCancionPublicada(id, nuevoPublicado);
      
      // Actualizar la canción en la lista local para refrescar la UI de forma reactiva
      final index = _canciones.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        _canciones[index]['publicado'] = nuevoPublicado;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Obtiene la lista de canciones públicas (publicado=true) de un artista específico.
  /// Se utiliza principalmente en la vista de fans para la reproducción musical en el modal de detalles del artista.
  Future<List<dynamic>> loadCancionesDeArtista(int artistaId) async {
    try {
      return await _repository.getCancionesPorArtista(artistaId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
