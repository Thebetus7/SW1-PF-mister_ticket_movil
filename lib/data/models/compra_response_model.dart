// ── Resultado sellado de la compra ───────────────────────────────────────────
//
// CompraResult es el tipo que devuelve CompraService.realizarCompra().
// Permite al provider y a la UI distinguir exactamente qué flujo ocurrió:
//
//   CompraStripeResult   → pago síncrono completado; contiene tickets y factura.
//   CompraLibelulaResult → reserva creada; contiene la URL del WebView de pago.
//
sealed class CompraResult {}

class CompraStripeResult extends CompraResult {
  final CompraResponseModel compraResponse;
  CompraStripeResult(this.compraResponse);
}

class CompraLibelulaResult extends CompraResult {
  final String urlPasarela;
  CompraLibelulaResult(this.urlPasarela);
}

// ── Modelos de datos ──────────────────────────────────────────────────────────

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
    final ticketList = json['tickets'] as List? ?? [];
    return CompraResponseModel(
      facturaId: json['factura_id'] as int,
      estadoPago: json['estado_pago'] as String? ?? '',
      precioTotal:
          double.tryParse(json['precio_total']?.toString() ?? '0') ?? 0.0,
      stripePaymentIntentId:
          json['stripe_payment_intent_id'] as String? ?? '',
      tickets: ticketList
          .map((t) => TicketCompradoModel.fromJson(t as Map<String, dynamic>))
          .toList(),
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
      id: json['id'] as int,
      codigoQr: json['codigo_qr'] as String? ?? '',
      zonaNombre: json['zona_nombre'] as String? ?? '',
      eventoNombre: json['evento_nombre'] as String? ?? '',
      eventoFecha: json['evento_fecha'] != null
          ? DateTime.parse(json['evento_fecha'] as String)
          : DateTime.now(),
      asientoDetalle: json['asiento_detalle'] != null
          ? AsientoDetalleModel.fromJson(
              json['asiento_detalle'] as Map<String, dynamic>)
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
      id: json['id'] as int,
      fila: json['fila'] as int? ?? 0,
      columna: json['columna'] as int? ?? 0,
    );
  }
}
