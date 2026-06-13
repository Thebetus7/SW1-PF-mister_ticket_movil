import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'api_exceptions.dart';
import 'api_response.dart';

/// Cliente HTTP genérico centralizado.
/// Es el ÚNICO punto de contacto con la red.
/// NO se usa directamente desde Services — siempre a través de un ModuleApi.
class ApiClient {
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 30);

  // ─── Headers ───
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── GET ───
  Future<ApiResponse> get(String url,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      final response =
          await _client.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── POST ───
  Future<ApiResponse> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── PUT ───
  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── DELETE ───
  Future<ApiResponse> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response =
          await _client.delete(Uri.parse(url), headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── PATCH ───
  Future<ApiResponse> patch(String url, {Map<String, dynamic>? body}) async {
    try {
      final headers = await _getHeaders();
      final response = await _client
          .patch(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── Manejo de respuesta ───
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic body;
    
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = null;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isNotEmpty && body == null) {
        throw ApiException('La respuesta del servidor no tiene formato JSON válido', statusCode: statusCode);
      }
      return ApiResponse(success: true, data: body, statusCode: statusCode);
    }

    String errorMessage = 'Error inesperado ($statusCode)';
    if (body != null) {
      if (body is Map) {
        if (body.containsKey('detail')) {
          errorMessage = body['detail'].toString();
        } else if (body.containsKey('non_field_errors')) {
          final nfe = body['non_field_errors'];
          if (nfe is List) {
            errorMessage = nfe.join(', ');
          } else {
            errorMessage = nfe.toString();
          }
        } else {
          final fieldsErrors = <String>[];
          body.forEach((key, value) {
            if (value is List) {
              fieldsErrors.add('$key: ${value.join(', ')}');
            } else {
              fieldsErrors.add('$key: $value');
            }
          });
          if (fieldsErrors.isNotEmpty) {
            errorMessage = fieldsErrors.join('\n');
          }
        }
      } else if (body is String) {
        errorMessage = body;
      }
    }

    switch (statusCode) {
      case 400:
        throw ValidationApiException(errorMessage, errors: body);
      case 401:
        throw UnauthorizedException(
            'Sesión expirada. Inicie sesión nuevamente.');
      case 403:
        throw ForbiddenException('No tiene permisos para esta acción.');
      case 404:
        throw NotFoundException('Recurso no encontrado.');
      case 422:
        throw ValidationApiException('Error de validación.', errors: body);
      case 500:
        throw ServerException('Error interno del servidor.');
      default:
        throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // ─── POST Multipart (para subida de archivos inicial) ───
  Future<ApiResponse> postMultipart(
    String url, {
    required XFile file,
    required String fileFieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        fileFieldName,
        bytes,
        filename: file.name,
      ));

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  // ─── PATCH Multipart (para subida de archivos) ───

  Future<ApiResponse> patchMultipart(
    String url, {
    required XFile file,
    required String fileFieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PATCH', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Agregar campos de texto (datos del formulario)
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Agregar el archivo como bytes para compatibilidad web/móvil
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        fileFieldName,
        bytes,
        filename: file.name,
      ));

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } on http.ClientException {
      throw NetworkException('Error de conexión con el servidor');
    }
  }

  void dispose() {
    _client.close();
  }
}
