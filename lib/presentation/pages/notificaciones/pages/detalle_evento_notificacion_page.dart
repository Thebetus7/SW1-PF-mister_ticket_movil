import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/notificacion_provider.dart';
import '../../../state/profile_provider.dart';
import '../../compra/seleccion_zona_page.dart';

class DetalleEventoNotificacionPage extends StatefulWidget {
  final int eventoId;

  const DetalleEventoNotificacionPage({super.key, required this.eventoId});

  @override
  State<DetalleEventoNotificacionPage> createState() => _DetalleEventoNotificacionPageState();
}

class _DetalleEventoNotificacionPageState extends State<DetalleEventoNotificacionPage> {
  Map<String, dynamic>? _evento;
  bool _loading = true;
  String? _error;
  late final List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
    
    // Degradado visual por defecto
    final gradients = [
      [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)],
      [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
      [const Color(0xFF7F00FF), const Color(0xFFE100FF)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    ];
    _gradientColors = gradients[widget.eventoId % gradients.length];
  }

  Future<void> _cargarDetalles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await Provider.of<NotificacionProvider>(context, listen: false)
          .cargarEventoDetalle(widget.eventoId);
      setState(() {
        _evento = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los detalles del evento.';
        _loading = false;
      });
    }
  }

  String _formatFecha(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatHora(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isFan = profileProvider.roles.contains('fan');
    final isArtista = profileProvider.roles.contains('artista');
    final nombreArtisticoUser = profileProvider.nombreArtistico?.toLowerCase() ?? '';
    final nombreEvento = _evento?['nombre'] ?? 'Sin nombre';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6FF7)))
          : _error != null
              ? _buildErrorWidget()
              : _buildContentWidget(isFan, isArtista, nombreArtisticoUser),
      floatingActionButton: (!_loading && _error == null && isFan)
          ? _buildFloatingButton(nombreEvento)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargarDetalles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FF7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget(bool isFan, bool isArtista, String nombreArtisticoUser) {
    final themeColor = Theme.of(context).primaryColor;
    final nombreEvento = _evento?['nombre'] ?? 'Sin nombre';
    final lugarNombre = _evento?['lugar_nombre'] ?? 'Sin sede asignada';
    final promotorNombre = _evento?['promotor_razon'] ?? 'Organizador';
    final fechaInicio = _evento?['fecha_inicio'];
    final presentaciones = _evento?['presentaciones'] as List? ?? [];

    // Comprobar si el artista logueado está en el elenco
    Map<String, dynamic>? presentacionPropia;
    if (isArtista && nombreArtisticoUser.isNotEmpty) {
      for (var pres in presentaciones) {
        final artistaData = pres['artista'];
        if (artistaData != null) {
          final nombreArt = (artistaData['nombre_artistico'] as String? ?? '').toLowerCase();
          if (nombreArt == nombreArtisticoUser) {
            presentacionPropia = pres;
            break;
          }
        }
      }
    }

    return CustomScrollView(
      slivers: [
        // Cabecera con colapso y el degradado del evento
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: const Color(0xFF0F0F1A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.85)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            promotorNombre.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nombreEvento.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Cuerpo del Detalle
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de Info General
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A4E)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    lugarNombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, color: themeColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _formatFecha(fechaInicio),
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time_rounded, color: themeColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Inicio: ${_formatHora(fechaInicio)}',
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // ── Tarjeta flotante especial si el usuario es Artista y es parte del elenco ──
                if (isArtista && presentacionPropia != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              '¡Estás en este elenco!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Detalles de tu presentación:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orden en el escenario:',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                            ),
                            Text(
                              '#${presentacionPropia['orden_aparicion']}',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hora de salida:',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                            ),
                            Text(
                              _formatHora(presentacionPropia['tiempo_inicio']),
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Título de Elenco
                const Text(
                  'Elenco de Artistas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Lista de Artistas
                if (presentaciones.isEmpty)
                  Text(
                    'No hay artistas asignados a este elenco.',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: presentaciones.length,
                    itemBuilder: (context, index) {
                      final pres = presentaciones[index];
                      final artista = pres['artista'];
                      if (artista == null) return const SizedBox.shrink();

                      final String nombreArt = artista['nombre_artistico'] ?? 'Artista';
                      final String? foto = artista['foto_url'];
                      final int popularidad = artista['popularidad'] ?? 0;
                      final int orden = pres['orden_aparicion'] ?? (index + 1);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A4E), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            // Foto o inicial
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: themeColor.withOpacity(0.2),
                              backgroundImage: (foto != null && foto.isNotEmpty)
                                  ? NetworkImage(foto)
                                  : null,
                              child: (foto == null || foto.isEmpty)
                                  ? Text(
                                      nombreArt[0].toUpperCase(),
                                      style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            
                            // Info Artista
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombreArt,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Popularidad: $popularidad/100',
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Badge de Orden
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A4E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$orden',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 100), // Espacio para el botón de compra
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton(String nombreEvento) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6FF7).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeleccionZonaPage(
                  eventoId: widget.eventoId,
                  eventoNombre: nombreEvento,
                ),
              ),
            );
          },
          child: const Text(
            'Comprar Boletos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
