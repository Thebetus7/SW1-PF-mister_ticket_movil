import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/repositories/profile_repository.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../core/constants/api_constants.dart';

/// Estado global del perfil del usuario autenticado.
/// Gestiona la carga, actualización de datos y subida de foto.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Roles del usuario autenticado
  List<String> get roles {
    if (_profileData == null) return [];
    final r = _profileData!['roles'];
    if (r == null) return [];
    return List<String>.from(r);
  }

  /// Verifica si el usuario puede acceder a la pantalla de perfil
  bool get puedeVerPerfil {
    return roles.contains('artista') || roles.contains('fan');
  }

  /// Verifica si el usuario es artista
  bool get esArtista => roles.contains('artista');

  // ─── Getters de datos de perfil ───

  String get username => _profileData?['username'] ?? '';
  String get email => _profileData?['email'] ?? '';
  String get firstName => _profileData?['first_name'] ?? '';
  String get lastName => _profileData?['last_name'] ?? '';
  
  String? get fotoUrl {
    final rawUrl = _profileData?['foto_url'];
    if (rawUrl == null) return null;

    String targetHost = '10.0.2.2'; // Por defecto emulador
    try {
      final uri = Uri.parse(ApiConstants.baseUrl);
      if (uri.host.isNotEmpty) {
        targetHost = uri.host;
      }
    } catch (_) {}

    // Si la URL contiene localhost o 127.0.0.1 y estamos en móvil, la cambiamos al host del backend
    // para que el emulador Android local o el celular puedan conectarse a MinIO en la PC host.
    if (!kIsWeb && (rawUrl.contains('localhost:9000') || rawUrl.contains('127.0.0.1:9000'))) {
      return rawUrl
          .replaceAll('localhost:9000', '$targetHost:9000')
          .replaceAll('127.0.0.1:9000', '$targetHost:9000');
    }
    return rawUrl;
  }

  String? get nombreCompleto => _profileData?['nombre_completo'];
  String? get ci => _profileData?['ci'];
  String? get nombreArtistico => _profileData?['nombre_artistico'];
  String? get biografia => _profileData?['biografia'];

  /// Carga el perfil del usuario desde la API
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profileData = await _repository.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza los datos de texto del perfil
  Future<bool> updateProfileData(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProfileData(data);
      _profileData = {...?_profileData, ...updated};
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

  /// Actualiza la foto de perfil y opcionalmente otros campos
  Future<bool> updateProfileWithPhoto({
    required XFile foto,
    Map<String, String>? fields,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateProfileWithPhoto(
        foto: foto,
        fields: fields,
      );
      _profileData = {...?_profileData, ...updated};
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
