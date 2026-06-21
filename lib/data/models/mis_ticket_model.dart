import 'compra_response_model.dart'; // Reutilizamos AsientoDetalleModel

class MisTicketModel {
  final int id;
  final String codigoQr;
  final String estado;
  final String zonaNombre;
  final String eventoNombre;
  final DateTime eventoFecha;
  final AsientoDetalleModel? asientoDetalle;
  final bool transferido;
  final bool transferible;
  final DateTime createdAt;

  MisTicketModel({
    required this.id,
    required this.codigoQr,
    required this.estado,
    required this.zonaNombre,
    required this.eventoNombre,
    required this.eventoFecha,
    required this.asientoDetalle,
    required this.transferido,
    required this.transferible,
    required this.createdAt,
  });

  factory MisTicketModel.fromJson(Map<String, dynamic> json) {
    return MisTicketModel(
      id: json['id'],
      codigoQr: json['codigo_qr'] ?? '',
      estado: json['estado'] ?? '',
      zonaNombre: json['zona_nombre'] ?? '',
      eventoNombre: json['evento_nombre'] ?? '',
      eventoFecha: json['evento_fecha'] != null
          ? DateTime.parse(json['evento_fecha'])
          : DateTime.now(),
      asientoDetalle: json['asiento_detalle'] != null
          ? AsientoDetalleModel.fromJson(json['asiento_detalle'])
          : null,
      transferido: json['transferido'] ?? false,
      transferible: json['transferible'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
