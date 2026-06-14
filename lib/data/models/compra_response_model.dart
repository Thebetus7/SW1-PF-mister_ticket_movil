class CompraResponseModel {
  final int facturaId;
  final String estadoPago;
  final double precioTotal;
  final String stripePaymentIntentId;
  final List<TicketCompradoModel> tickets;

  CompraResponseModel({
    required this.facturaId,
    required this.estadoPago,
    required this.precioTotal,
    required this.stripePaymentIntentId,
    required this.tickets,
  });

  factory CompraResponseModel.fromJson(Map<String, dynamic> json) {
    var ticketList = json['tickets'] as List? ?? [];
    List<TicketCompradoModel> parsedTickets =
        ticketList.map((t) => TicketCompradoModel.fromJson(t)).toList();

    return CompraResponseModel(
      facturaId: json['factura_id'],
      estadoPago: json['estado_pago'] ?? '',
      precioTotal: double.tryParse(json['precio_total']?.toString() ?? '0.0') ?? 0.0,
      stripePaymentIntentId: json['stripe_payment_intent_id'] ?? '',
      tickets: parsedTickets,
    );
  }
}

class TicketCompradoModel {
  final int id;
  final String codigoQr;
  final String zonaNombre;
  final String eventoNombre;
  final DateTime eventoFecha;
  final AsientoDetalleModel? asientoDetalle;

  TicketCompradoModel({
    required this.id,
    required this.codigoQr,
    required this.zonaNombre,
    required this.eventoNombre,
    required this.eventoFecha,
    required this.asientoDetalle,
  });

  factory TicketCompradoModel.fromJson(Map<String, dynamic> json) {
    return TicketCompradoModel(
      id: json['id'],
      codigoQr: json['codigo_qr'] ?? '',
      zonaNombre: json['zona_nombre'] ?? '',
      eventoNombre: json['evento_nombre'] ?? '',
      eventoFecha: json['evento_fecha'] != null
          ? DateTime.parse(json['evento_fecha'])
          : DateTime.now(),
      asientoDetalle: json['asiento_detalle'] != null
          ? AsientoDetalleModel.fromJson(json['asiento_detalle'])
          : null,
    );
  }
}

class AsientoDetalleModel {
  final int id;
  final int fila;
  final int columna;

  AsientoDetalleModel({
    required this.id,
    required this.fila,
    required this.columna,
  });

  factory AsientoDetalleModel.fromJson(Map<String, dynamic> json) {
    return AsientoDetalleModel(
      id: json['id'],
      fila: json['fila'] ?? 0,
      columna: json['columna'] ?? 0,
    );
  }
}
