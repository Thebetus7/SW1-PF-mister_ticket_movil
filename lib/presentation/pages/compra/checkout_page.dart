import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../../state/compra_provider.dart';
import 'confirmacion_compra_page.dart';

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
  bool _cardComplete = false;
  bool _isProcessing = false;


  Future<void> _handlePayment() async {
    if (!_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa los datos completos de tu tarjeta.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final compraProvider = Provider.of<CompraProvider>(context, listen: false);

    try {
      // 1. Crear el PaymentMethod en los servidores de Stripe de manera segura
      // Stripe lee internamente el widget CardField activo
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // 2. Enviar el ID del PaymentMethod a nuestro backend
      final success = await compraProvider.comprar(
        eventoId: widget.eventoId,
        zonaId: widget.zonaId,
        cantidad: widget.cantidad,
        paymentMethodId: paymentMethod.id,
      );

      if (success && mounted) {
        // Redirigir a confirmación de compra pasándole la respuesta exitosa
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacionCompraPage(
              compraResponse: compraProvider.compraResponse!,
            ),
          ),
          (route) => route.isFirst, // Limpia el historial para no poder volver atrás al checkout
        );
      } else if (mounted) {
        // Mostrar error retornado del backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(compraProvider.error ?? 'Error al procesar la compra.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en pasarela de pagos: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7C6FF7);
    final backgroundColor = const Color(0xFF0F0F1A);
    final cardColor = const Color(0xFF161626);

    double subtotal = widget.precioUnitario * widget.cantidad;
    double serviceFee = subtotal * 0.05; // 5% de tarifa ficticia
    double total = subtotal + serviceFee;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Sección 1: Resumen del Pedido (Review Order)
            const Text(
              'RESUMEN DE TU COMPRA',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.eventoNombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Zona: ${widget.zonaNombre}',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.cantidad} x Boletos',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '${subtotal.toStringAsFixed(2)} BOB',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cargo por servicio (5%)',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      Text(
                        '${serviceFee.toStringAsFixed(2)} BOB',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a pagar',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} BOB',
                        style: const TextStyle(
                          color: Color(0xFFE100FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Sección 2: Método de Pago (Payment Method con Stripe CardField)
            const Text(
              'DATOS DE PAGO',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Tarjeta de Crédito / Débito',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  
                  // Campo de Tarjeta seguro de Stripe
                  CardField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeColor),
                      ),
                    ),
                    onCardChanged: (card) {
                      setState(() {
                        _cardComplete = card?.complete ?? false;
                      });
                    },

                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Certificado de Seguridad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'SECURED BY 256-BIT SSL ENCRYPTION',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Botón de Pago
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6FF7).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: _isProcessing ? null : _handlePayment,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'COMPLETAR COMPRA - ${total.toStringAsFixed(2)} BOB',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Texto legal
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Al completar tu compra, aceptas los Términos de Servicio y la Política de Privacidad de MisterTicket. Esta es una transacción con fines académicos.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
