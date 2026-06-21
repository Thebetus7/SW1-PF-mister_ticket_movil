import 'package:image_picker/image_picker.dart' show XFile;
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class CancionRepository {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getCanciones() async {
    final response = await _client.get(ApiConstants.canciones);
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> uploadCancion({
    required XFile archivo,
    required String nombre,
    required String detalle,
  }) async {
    final fields = {
      'nombre': nombre,
      'detalle': detalle,
    };
    final response = await _client.postMultipart(
      ApiConstants.canciones,
      file: archivo,
      fileFieldName: 'archivo',
      fields: fields,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteCancion(int id) async {
    await _client.delete('${ApiConstants.canciones}$id/');
  }

  Future<Map<String, dynamic>> updateCancionPublicada(int id, bool publicado) async {
    final response = await _client.patch(
      '${ApiConstants.canciones}$id/',
      body: {'publicado': publicado},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getCancionesPorArtista(int artistaId) async {
    final response = await _client.get('${ApiConstants.canciones}?artista_id=$artistaId');
    return response.data as List<dynamic>;
  }
}
