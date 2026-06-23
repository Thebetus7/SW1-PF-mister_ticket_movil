import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/compra_provider.dart';
import '../../../data/models/compra_response_model.dart';
import '../../../data/models/zona_model.dart';
import 'checkout_page.dart';
import 'confirmacion_compra_page.dart';
import 'libelula_webview_screen.dart';


class SeleccionZonaPage extends StatefulWidget {
  final int eventoId;
  final String eventoNombre;

  const SeleccionZonaPage({
    super.key,
    required this.eventoId,
    required this.eventoNombre,
  });

  @override
  State<SeleccionZonaPage> createState() => _SeleccionZonaPageState();
}

class _SeleccionZonaPageState extends State<SeleccionZonaPage> {
  // Mapa de ID de Zona -> Cantidad seleccionada (para persistir valores en el UI)
  final Map<int, int> _cantidades = {};
  int? _selectedZonaId;
  int _cantidad = 0;
  bool _isProcessingDirect = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompraProvider>(context, listen: false)
          .loadZonas(widget.eventoId);
    });
  }

  void _updateCantidad(int zonaId, int newCantidad, int maxDisponibles) {
    if (newCantidad < 0 || newCantidad > maxDisponibles) return;

    setState(() {
      if (newCantidad == 0) {
        _cantidades[zonaId] = 0;
        if (_selectedZonaId == zonaId) {
          _selectedZonaId = null;
          _cantidad = 0;
        }
      } else {
        // Al seleccionar cantidad >= 1 en una zona,
        // todas las demás zonas se restablecen a 0 (solo se puede comprar de una zona por orden)
        _cantidades.clear();
        _cantidades[zonaId] = newCantidad;
        _selectedZonaId = zonaId;
        _cantidad = newCantidad;
      }
    });
  }

  void _showPaymentOptions(BuildContext context, ZonaModel selectedZona) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        final themeColor = const Color(0xFF7C6FF7);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Elige tu método de pago',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${(selectedZona.precio * _cantidad).toStringAsFixed(2)} BOB',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Opción 1: Stripe (Tarjeta)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx); // Cerrar bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          eventoId: widget.eventoId,
                          eventoNombre: widget.eventoNombre,
                          zonaId: selectedZona.id,
                          zonaNombre: selectedZona.nombre,
                          cantidad: _cantidad,
                          precioUnitario: selectedZona.precio,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.credit_card_rounded, color: Colors.white),
                  label: const Text('PAGAR CON TARJETA (STRIPE)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C4E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Opción 2: Compra Directa (Simulado/Desarrollo)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx); // Cerrar bottom sheet
                    _ejecutarCompraDirecta(selectedZona);
                  },
                  icon: const Icon(Icons.flash_on_rounded, color: Colors.amber),
                  label: const Text('COMPRA DIRECTA (DESARROLLO)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5E3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Opción 3: Libélula (QR)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _ejecutarCompraLibelula(selectedZona);
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                  label: const Text('PAGAR CON QR (LIBÉLULA)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _ejecutarCompraDirecta(ZonaModel selectedZona) async {
    setState(() {
      _isProcessingDirect = true;
    });

    final provider = Provider.of<CompraProvider>(context, listen: false);
    final result = await provider.comprar(
      eventoId: widget.eventoId,
      zonaId: selectedZona.id,
      cantidad: _cantidad,
      metodoPago: 'stripe',
      paymentMethodId: 'pm_desarrollo_directo',
    );

    if (mounted) {
      setState(() {
        _isProcessingDirect = false;
      });

      if (result != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmacionCompraPage(
              compraResponse: provider.compraResponse!,
            ),
          ),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al procesar la compra directa.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  Future<void> _ejecutarCompraLibelula(ZonaModel selectedZona) async {
    setState(() => _isProcessingDirect = true);

    final provider = Provider.of<CompraProvider>(context, listen: false);
    final result = await provider.comprar(
      eventoId: widget.eventoId,
      zonaId: selectedZona.id,
      cantidad: _cantidad,
      metodoPago: 'libelula',
      urlRetorno: 'miapp://pago-completado',
    );

    if (!mounted) return;
    setState(() => _isProcessingDirect = false);

    if (result is CompraLibelulaResult) {
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
          arguments: 2, // pestaña Mis Tickets
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva pendiente. Tienes 15 minutos para completar el pago.'),
            backgroundColor: Color(0xFF7C6FF7),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al crear la reserva con Libélula.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF7C6FF7);
    final backgroundColor = const Color(0xFF0F0F1A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Consumer<CompraProvider>(
            builder: (context, provider, child) {

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Ocurrió un error al cargar las zonas:',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadZonas(widget.eventoId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.zonas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay zonas de entradas disponibles para este evento.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                    child: const Text('Volver al Feed'),
                  ),
                ],
              ),
            );
          }

          // Inicializar selección predeterminada (primer zona con cantidad 1) si no hay nada seleccionado aún
          if (_selectedZonaId == null && provider.zonas.isNotEmpty && _cantidad == 0) {
            final primeraZona = provider.zonas.first;
            _selectedZonaId = primeraZona.id;
            _cantidad = 1;
            _cantidades[_selectedZonaId!] = 1;
          }

          // Resolver zona seleccionada
          ZonaModel? selectedZona;
          if (_selectedZonaId != null) {
            try {
              selectedZona = provider.zonas.firstWhere((z) => z.id == _selectedZonaId);
            } catch (_) {
              selectedZona = null;
            }
          }

          double total = 0.0;
          if (selectedZona != null) {
            total = selectedZona.precio * _cantidad;
          }

          return Column(
            children: [
              // 1. Header con Banner Superior
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.85)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.eventoNombre.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Selecciona tu zona y la cantidad de boletos',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Lista de Zonas Rediseñada
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: provider.zonas.length,
                  itemBuilder: (context, index) {
                    final zona = provider.zonas[index];
                    final isSelected = _selectedZonaId == zona.id;
                    final cantidadAct = _cantidades[zona.id] ?? 0;

                    // Badges y descripciones estilizadas según el nombre de la zona
                    String badgeText = "ENTRY ONLY";
                    Color badgeColor = Colors.white24;
                    String descText = "Acceso estándar al área seleccionada.";

                    if (zona.nombre.toUpperCase().contains("VIP")) {
                      badgeText = "MOST POPULAR";
                      badgeColor = const Color(0xFFFF416C);
                      descText = "Acceso exclusivo, áreas preferenciales y visibilidad Premium.";
                    } else if (zona.nombre.toUpperCase().contains("SUPER") || 
                               zona.nombre.toUpperCase().contains("ELITE") ||
                               zona.nombre.toUpperCase().contains("GOLD")) {
                      badgeText = "ELITE";
                      badgeColor = Colors.amber.shade700;
                      descText = "Experiencia definitiva, la mejor ubicación acústica e interacción.";
                    }

                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          _updateCantidad(zona.id, 1, zona.entradasDisponibles);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E1E36) : const Color(0xFF161626),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? themeColor : Colors.white.withOpacity(0.04),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: themeColor.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabecera: Nombre de la Zona y Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    zona.nombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Descripción
                            Text(
                              descText,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Fila de Precio, Disponibilidad y Contador Compacto
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Sección de Precio y Disponibilidad a la izquierda
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${zona.precio.toStringAsFixed(2)} BOB',
                                        style: TextStyle(
                                          color: isSelected ? const Color(0xFFE100FF) : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${zona.entradasDisponibles} entradas disponibles',
                                        style: TextStyle(
                                          color: zona.entradasDisponibles < 10
                                              ? Colors.redAccent
                                              : Colors.white30,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Selector de cantidad ovalado compacto (110px de ancho)
                                Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected ? themeColor.withOpacity(0.12) : Colors.black.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? themeColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Botón menos circular
                                      GestureDetector(
                                        onTap: cantidadAct > 0
                                            ? () => _updateCantidad(zona.id, cantidadAct - 1, zona.entradasDisponibles)
                                            : null,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            color: cantidadAct > 0 ? Colors.white : Colors.white24,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      // Cantidad en medio
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 24),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$cantidadAct',
                                          style: TextStyle(
                                            color: cantidadAct > 0 ? Colors.white : Colors.white38,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Botón más circular
                                      GestureDetector(
                                        onTap: () => _updateCantidad(zona.id, cantidadAct + 1, zona.entradasDisponibles),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Barra Fija de Compra Total Inferior Responsiva (Evita Overflows)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161626),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Detalle del Total (Flexible)
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL DE INVERSIÓN',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${total.toStringAsFixed(2)} BOB',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedZona != null
                                  ? '$_cantidad x ${selectedZona.nombre}'
                                  : 'Ninguna zona seleccionada',
                              style: TextStyle(
                                color: selectedZona != null ? themeColor : Colors.white24,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Botón Proceder Checkout (Flexible)
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: selectedZona != null
                                ? const LinearGradient(
                                    colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
                                  )
                                : null,
                            color: selectedZona == null ? Colors.white12 : null,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: selectedZona != null
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF7C6FF7).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: selectedZona != null
                                ? () => _showPaymentOptions(context, selectedZona!)
                                : null,


                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CHECKOUT',
                                  style: TextStyle(
                                    color: selectedZona != null ? Colors.white : Colors.white30,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: selectedZona != null ? Colors.white : Colors.white30,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
            },
          ),
          if (_isProcessingDirect)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF7C6FF7)),
                    SizedBox(height: 16),
                    Text(
                      'Procesando compra directa...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

