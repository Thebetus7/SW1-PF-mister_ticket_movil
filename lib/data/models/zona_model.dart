class ZonaModel {
  final int id;
  final String nombre;
  final double precio;
  final int entradasDisponibles;
  final int capacidadMax;
  final bool esNumerada;

  ZonaModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.entradasDisponibles,
    required this.capacidadMax,
    required this.esNumerada,
  });

  factory ZonaModel.fromJson(Map<String, dynamic> json) {
    return ZonaModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      precio: double.tryParse(json['precio']?.toString() ?? '0.0') ?? 0.0,
      entradasDisponibles: json['entradas_disponibles'] ?? 0,
      capacidadMax: json['capacidad_max'] ?? 0,
      esNumerada: json['es_numerada'] ?? false,
    );
  }
}
