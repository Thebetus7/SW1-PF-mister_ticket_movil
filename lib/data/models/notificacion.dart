class NotificacionModel {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leido;
  final int? eventoId;
  final String? eventoNombre;
  final DateTime createdAt;

  NotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leido,
    this.eventoId,
    this.eventoNombre,
    required this.createdAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? '',
      leido: json['leido'] ?? false,
      eventoId: json['evento_id'],
      eventoNombre: json['evento_nombre'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'leido': leido,
      'evento_id': eventoId,
      'evento_nombre': eventoNombre,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
