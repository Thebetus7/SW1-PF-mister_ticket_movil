import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/evento_feed.dart';
import '../../state/profile_provider.dart';
import '../compra/seleccion_zona_page.dart';
import 'widgets/evento_interacciones_bar.dart';
import 'widgets/evento_elenco_seccion.dart';

class EventoFeedCard extends StatefulWidget {
  final EventoFeedModel evento;

  const EventoFeedCard({super.key, required this.evento});

  @override
  State<EventoFeedCard> createState() => _EventoFeedCardState();
}

class _EventoFeedCardState extends State<EventoFeedCard> {
  late final List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    // Generar un degradado único para cada evento como fondo visual representativo
    final gradients = [
      [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)],
      [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
      [const Color(0xFF7F00FF), const Color(0xFFE100FF)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
      [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
    ];
    _gradientColors = gradients[widget.evento.id % gradients.length];
  }

  String _formatFecha(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatHora(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isFan = profileProvider.roles.contains('fan');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabecera (Organizador / Promotor)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: themeColor.withOpacity(0.2),
                  child: Icon(Icons.music_note_rounded, color: themeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.evento.promotorRazon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: Colors.blue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Organizador verificado',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 2. Banner Visual del Evento (Degradado con tipografía del evento)
          AspectRatio(
            aspectRatio: 1.77, // 16:9
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Superposición oscura para legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.75)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  
                  // Luces de fondo (Efecto fiesta)
                  Positioned(
                    right: -20,
                    top: -20,
                    child: ClipOval(
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  // Texto del Evento en el banner
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Corrección de Overflow: Título del evento con límite de 2 líneas
                        Text(
                          widget.evento.nombre.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.evento.lugarNombre,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Detalle del Evento (Fecha, Hora, etc.) - Centrado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, color: themeColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Fecha: ${_formatFecha(widget.evento.fechaInicio)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(width: 20),
                Icon(Icons.access_time_rounded, color: themeColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Inicio: ${_formatHora(widget.evento.fechaInicio)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),

          // 4. Botón Comprar Boletos - Centrado y con dimensiones fijas (Solo visible para fans)
          if (isFan)
            Center(
              child: Container(
                width: 180,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C6FF7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeleccionZonaPage(
                          eventoId: widget.evento.id,
                          eventoNombre: widget.evento.nombre,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Comprar Boletos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),

          // 5. Elenco (Componente Separado)
          EventoElencoSeccion(
            evento: widget.evento,
            presentaciones: widget.evento.presentaciones,
          ),

          // 6. Barra de Acciones Estilo Red Social (Componente Separado)
          EventoInteraccionesBar(
            evento: widget.evento,
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
