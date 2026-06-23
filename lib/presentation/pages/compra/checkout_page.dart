import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../state/compra_provider.dart';
import '../../../data/models/compra_response_model.dart';
import 'confirmacion_compra_page.dart';
import 'libelula_webview_screen.dart';

// Deep-link que Libelula usa como URL de retorno.
// Debe coincidir exactamente con el que intercepta LibelulaWebViewScreen.
const _kUrlRetorno = 'miapp://pago-completado';

class CheckoutPage extends StatefulWidget {
  final int eventoId;
  final String eventoNombre;
  final int zonaId;
  final String zonaNombre;
  final int cantidad;
  final double precioUnitario;

  const CheckoutPage({
    super.key,
    required this.eventoId,
    required this.eventoNombre,
    required this.zonaId,
    required this.zonaNombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // 'stripe' | 'libelula'
  String _metodoPago = 'stripe';
  bool _cardComplete = false;
  bool _isProcessing = false;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _handlePayment() async {
    if (_metodoPago == 'stripe') {
      await _handleStripe();
    } else {
      await _handleLibelula();
    }
  }

  Future<void> _handleStripe() async {
    if (!_cardComplete) {
      _showError('Por favor, ingresa los datos completos de tu tarjeta.');
      return;
    }

    setState(() => _isProcessing = true);
    final compraProvider = context.read<CompraProvider>();

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      final result = await compraProvider.comprar(
        eventoId: widget.eventoId,
        zonaId: widget.zonaId,
        cantidad: widget.cantidad,
        metodoPago: 'stripe',
        paymentMethodId: paymentMethod.id,
      );

      if (!mounted) return;

      if (result is CompraStripeResult) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ConfirmacionCompraPage(compraResponse: result.compraResponse),
          ),
          (route) => route.isFirst,
        );
      } else {
        _showError(compraProvider.error ?? 'Error al procesar la compra.');
      }
    } catch (e) {
      if (mounted) _showError('Error en pasarela de pagos: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleLibelula() async {
    setState(() => _isProcessing = true);
    final compraProvider = context.read<CompraProvider>();

    try {
      final result = await compraProvider.comprar(
        eventoId: widget.eventoId,
        zonaId: widget.zonaId,
        cantidad: widget.cantidad,
        metodoPago: 'libelula',
        urlRetorno: _kUrlRetorno,
      );

      if (!mounted) return;

      if (result is CompraLibelulaResult) {
        // Abrir WebView de Libelula; retorna true si el usuario pago
        final pagado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => LibelulaWebViewScreen(url: result.urlPasarela),
          ),
        );

        if (!mounted) return;

        if (pagado == true) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
            arguments: 2, // pestana Mis Tickets
          );
        } else {
          _showInfo(
            'Tu reserva esta pendiente de pago. '
            'Tienes 15 minutos para completarla.',
          );
        }
      } else {
        _showError(compraProvider.error ?? 'Error al crear la reserva.');
      }
    } catch (e) {
      if (mounted) _showError('Error inesperado: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showInfo(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF7C6FF7),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.precioUnitario * widget.cantidad;
    final serviceFee = subtotal * 0.05;
    final total = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('RESUMEN DE TU COMPRA'),
            const SizedBox(height: 10),
            _ResumenCard(
              eventoNombre: widget.eventoNombre,
              zonaNombre: widget.zonaNombre,
              cantidad: widget.cantidad,
              subtotal: subtotal,
              serviceFee: serviceFee,
              total: total,
            ),

            const SizedBox(height: 30),

            _sectionLabel('METODO DE PAGO'),
            const SizedBox(height: 10),
            _MetodoPagoSelector(
              seleccionado: _metodoPago,
              onChanged: (v) => setState(() {
                _metodoPago = v;
                _cardComplete = false;
              }),
            ),

            const SizedBox(height: 16),

            // CardField solo visible con Stripe
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _metodoPago == 'stripe'
                  ? _StripeCardSection(
                      key: const ValueKey('stripe'),
                      onCardChanged: (ok) =>
                          setState(() => _cardComplete = ok),
                    )
                  : _LibelulaInfoSection(key: const ValueKey('libelula')),
            ),

            const SizedBox(height: 35),

            _PayButton(
              isProcessing: _isProcessing,
              metodoPago: _metodoPago,
              total: total,
              onPressed: _handlePayment,
            ),

            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Al completar tu compra aceptas los Terminos de Servicio '
                  'y la Politica de Privacidad de MisterTicket. '
                  'Esta es una transaccion con fines academicos.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.25), fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _cardDeco() => BoxDecoration(
      color: const Color(0xFF161626),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.03)),
    );

class _ResumenCard extends StatelessWidget {
  final String eventoNombre;
  final String zonaNombre;
  final int cantidad;
  final double subtotal;
  final double serviceFee;
  final double total;

  const _ResumenCard({
    required this.eventoNombre,
    required this.zonaNombre,
    required this.cantidad,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eventoNombre,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Zona: $zonaNombre',
              style: const TextStyle(
                  color: Color(0xFF7C6FF7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _PriceRow(
              label: '$cantidad x Boletos',
              value: '${subtotal.toStringAsFixed(2)} BOB',
              labelColor: Colors.white70,
              valueColor: Colors.white),
          const SizedBox(height: 8),
          _PriceRow(
              label: 'Cargo por servicio (5%)',
              value: '${serviceFee.toStringAsFixed(2)} BOB',
              labelColor: Colors.white38,
              valueColor: Colors.white38,
              fontSize: 12),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Total a pagar',
            value: '${total.toStringAsFixed(2)} BOB',
            labelColor: Colors.white,
            valueColor: const Color(0xFFE100FF),
            labelFontSize: 15,
            valueFontSize: 18,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final double fontSize;
  final double? labelFontSize;
  final double? valueFontSize;
  final bool bold;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.fontSize = 13,
    this.labelFontSize,
    this.valueFontSize,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor,
                fontSize: labelFontSize ?? fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: valueFontSize ?? fontSize,
                fontWeight: bold ? FontWeight.w900 : FontWeight.bold)),
      ],
    );
  }
}

class _MetodoPagoSelector extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onChanged;

  const _MetodoPagoSelector(
      {required this.seleccionado, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetodoPagoTile(
            value: 'stripe',
            groupValue: seleccionado,
            icon: Icons.credit_card_rounded,
            label: 'Tarjeta',
            sublabel: 'Stripe',
            onTap: () => onChanged('stripe'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetodoPagoTile(
            value: 'libelula',
            groupValue: seleccionado,
            icon: Icons.qr_code_rounded,
            label: 'Pago QR',
            sublabel: 'Libelula',
            onTap: () => onChanged('libelula'),
          ),
        ),
      ],
    );
  }
}

class _MetodoPagoTile extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _MetodoPagoTile({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    const primary = Color(0xFF7C6FF7);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.15) : const Color(0xFF161626),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.white.withOpacity(0.06),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? primary : Colors.white38, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(sublabel,
                    style: TextStyle(
                        color: selected ? primary : Colors.white30,
                        fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StripeCardSection extends StatelessWidget {
  final ValueChanged<bool> onCardChanged;
  const _StripeCardSection({super.key, required this.onCardChanged});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7C6FF7);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 10),
              const Text('Tarjeta de Credito / Debito',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Image.network(
                'https://raw.githubusercontent.com/stripe/stripe-ios/master/Stripe/Resources/Images/stp_card_visa.png',
                height: 22,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 4),
              Image.network(
                'https://raw.githubusercontent.com/stripe/stripe-ios/master/Stripe/Resources/Images/stp_card_mastercard.png',
                height: 22,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CardField(
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primary),
              ),
            ),
            onCardChanged: (card) => onCardChanged(card?.complete ?? false),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  color: Colors.greenAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                'SECURED BY 256-BIT SSL ENCRYPTION',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibelulaInfoSection extends StatelessWidget {
  const _LibelulaInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7C6FF7);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pago con QR via Libelula',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Se creara una reserva y seras redirigido a la pasarela '
            'de Libelula para escanear el codigo QR y completar tu pago. '
            'Tu reserva expira en 15 minutos.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.55), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Colors.orangeAccent, size: 14),
              const SizedBox(width: 4),
              Text(
                'RESERVA VALIDA POR 15 MINUTOS',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final bool isProcessing;
  final String metodoPago;
  final double total;
  final VoidCallback onPressed;

  const _PayButton({
    required this.isProcessing,
    required this.metodoPago,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = metodoPago == 'stripe'
        ? 'PAGAR CON TARJETA  ${total.toStringAsFixed(2)} BOB'
        : 'RESERVAR Y PAGAR CON QR  ${total.toStringAsFixed(2)} BOB';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF7C6FF7).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26)),
          ),
          onPressed: isProcessing ? null : onPressed,
          child: isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      metodoPago == 'stripe'
                          ? Icons.lock_rounded
                          : Icons.qr_code_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.4),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
