class EventoFeedModel {
  final int id;
  final String nombre;
  final String estado;
  final String lugarNombre;
  final String promotorRazon;
  final int promotorId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime updatedAt;
  final List<PresentacionFeedModel> presentaciones;

  EventoFeedModel({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.lugarNombre,
    required this.promotorRazon,
    required this.promotorId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.updatedAt,
    required this.presentaciones,
  });

  factory EventoFeedModel.fromJson(Map<String, dynamic> json) {
    var presList = json['presentaciones'] as List? ?? [];
    List<PresentacionFeedModel> presentacionesList =
        presList.map((p) => PresentacionFeedModel.fromJson(p)).toList();

    return EventoFeedModel(
      id: json['id'],
      nombre: json['nombre'],
      estado: json['estado'] ?? '',
      lugarNombre: json['lugar_nombre'] ?? 'Sin lugar asignado',
      promotorRazon: json['promotor_razon'] ?? 'Sin promotor',
      promotorId: json['promotor'] ?? 0,
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.parse(json['fecha_inicio']),
      presentaciones: presentacionesList,
    );
  }
}

class PresentacionFeedModel {
  final int id;
  final int ordenAparicion;
  final DateTime tiempoInicio;
  final ArtistaFeedModel? artista;

  PresentacionFeedModel({
    required this.id,
    required this.ordenAparicion,
    required this.tiempoInicio,
    required this.artista,
  });

  factory PresentacionFeedModel.fromJson(Map<String, dynamic> json) {
    return PresentacionFeedModel(
      id: json['id'],
      ordenAparicion: json['orden_aparicion'] ?? 1,
      tiempoInicio: DateTime.parse(json['tiempo_inicio']),
      artista: json['artista'] != null
          ? ArtistaFeedModel.fromJson(json['artista'])
          : null,
    );
  }
}

class ArtistaFeedModel {
  final int id;
  final String nombreArtistico;
  final String biografia;
  final String? fotoUrl;
  final String? departamentoOrigenNombre;
  final int popularidad;
  final List<String> generosMusicalesNombres;

  ArtistaFeedModel({
    required this.id,
    required this.nombreArtistico,
    required this.biografia,
    required this.fotoUrl,
    required this.departamentoOrigenNombre,
    required this.popularidad,
    required this.generosMusicalesNombres,
  });

  factory ArtistaFeedModel.fromJson(Map<String, dynamic> json) {
    var genList = json['generos_musicales_nombres'] as List? ?? [];
    List<String> generos = genList.map((g) => g.toString()).toList();

    return ArtistaFeedModel(
      id: json['id'],
      nombreArtistico: json['nombre_artistico'] ?? 'Artista Desconocido',
      biografia: json['biografia'] ?? '',
      fotoUrl: json['foto_url'],
      departamentoOrigenNombre: json['departamento_origen_nombre'],
      popularidad: json['popularidad'] ?? 0,
      generosMusicalesNombres: generos,
    );
  }
}
