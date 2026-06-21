import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/evento_feed.dart';
import '../../compra/seleccion_zona_page.dart';
import '../../../state/cancion_provider.dart';
import '../../../state/profile_provider.dart';
import '../../musica/widgets/reproductor_flotante.dart';

class ArtistaDetallesModalWidget extends StatefulWidget {
  final ArtistaFeedModel artista;
  final EventoFeedModel evento;
  final PresentacionFeedModel pres;
  final String Function(DateTime) formatHoraFn;

  const ArtistaDetallesModalWidget({
    super.key,
    required this.artista,
    required this.evento,
    required this.pres,
    required this.formatHoraFn,
  });

  @override
  State<ArtistaDetallesModalWidget> createState() => _ArtistaDetallesModalWidgetState();
}

class _ArtistaDetallesModalWidgetState extends State<ArtistaDetallesModalWidget> {
  late Future<List<dynamic>> _cancionesFuture;
  Map<String, dynamic>? _cancionActiva;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _cancionesFuture = Provider.of<CancionProvider>(context, listen: false)
        .loadCancionesDeArtista(widget.artista.id);
  }

  void _reproducirCancion(Map<String, dynamic> cancion) {
    setState(() {
      if (_cancionActiva != null && _cancionActiva!['id'] == cancion['id']) {
        _isPlaying = !_isPlaying;
        if (!_isPlaying) {
          _cancionActiva = null;
        }
      } else {
        _cancionActiva = cancion;
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cancionProvider = Provider.of<CancionProvider>(context, listen: false);
    final themeColor = Theme.of(context).primaryColor;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isFan = profileProvider.roles.contains('fan');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Contenido principal scrollable
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 160), // Margen inferior extra por los reproductores y botones
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info del artista (Header)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto/Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: widget.artista.fotoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  cancionProvider.fixLocalhostUrl(widget.artista.fotoUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Nombre y popularidad
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.artista.nombreArtistico,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Estrellas de popularidad y cantidad de música al lado derecho
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    final isGold = index < widget.artista.popularidad;
                                    return Icon(
                                      Icons.star_rounded,
                                      color: isGold ? Colors.amber : Colors.white24,
                                      size: 16,
                                    );
                                  }),
                                ),
                                FutureBuilder<List<dynamic>>(
                                  future: _cancionesFuture,
                                  builder: (context, snapshot) {
                                    final count = snapshot.data?.length ?? 0;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.music_note_rounded,
                                          color: Color(0xFF7C6FF7),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$count ${count == 1 ? 'canción' : 'canciones'}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Badges de géneros
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: widget.artista.generosMusicalesNombres
                                  .map((g) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: themeColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: themeColor.withOpacity(0.3), width: 0.5),
                                        ),
                                        child: Text(
                                          g,
                                          style: TextStyle(
                                            color: themeColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detalles adicionales (Ubicación y Hora de Presentación)
                  // Corrección de Overflow: Reemplazo de Row por Wrap para diseño adaptivo
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (widget.artista.departamentoOrigenNombre != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.5), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              widget.artista.departamentoOrigenNombre!,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, color: Colors.white.withOpacity(0.5), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Presentación: ${widget.formatHoraFn(widget.pres.tiempoInicio)}',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Biografía
                  if (widget.artista.biografia.isNotEmpty) ...[
                    const Text(
                      'BIOGRAFÍA',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.artista.biografia,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Música del artista
                  const Text(
                    'MÚSICA DEL ARTISTA',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  FutureBuilder<List<dynamic>>(
                    future: _cancionesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error al cargar la música',
                            style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 13),
                          ),
                        );
                      }

                      final canciones = snapshot.data ?? [];
                      if (canciones.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.music_off_rounded, color: Colors.white.withOpacity(0.15), size: 40),
                              const SizedBox(height: 8),
                              Text(
                                'Este artista no ha publicado música todavía.',
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: canciones.length,
                        itemBuilder: (context, index) {
                          final cancion = canciones[index];
                          final id = cancion['id'];
                          final isSongPlaying = _cancionActiva != null &&
                              _cancionActiva!['id'] == id &&
                              _isPlaying;

                          return _CancionModalItem(
                            cancion: cancion,
                            isPlaying: isSongPlaying,
                            onPlayToggle: () => _reproducirCancion(cancion),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Botón de Compra Fijo (Solo visible si es Fan) y Reproductor Flotante en la parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFF0F0F1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.2],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón Comprar Boletos
                  if (isFan)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C6FF7), Color(0xFFE100FF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C6FF7).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            // Cerrar el modal antes de navegar
                            Navigator.pop(context);
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
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Reproductor flotante integrado
                  if (_cancionActiva != null)
                    ReproductorFlotante(
                      cancion: _cancionActiva!,
                      audioUrl: cancionProvider.fixLocalhostUrl(_cancionActiva!['archivo_url']),
                      onFinished: () {
                        setState(() {
                          _isPlaying = false;
                          _cancionActiva = null;
                        });
                      },
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

class _CancionModalItem extends StatelessWidget {
  final Map<String, dynamic> cancion;
  final bool isPlaying;
  final VoidCallback onPlayToggle;

  const _CancionModalItem({
    required this.cancion,
    required this.isPlaying,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = cancion['nombre'] ?? 'Sin título';
    final detalle = cancion['detalle'] ?? '';
    final duracion = cancion['duracion_formateada'] ?? '0:00';
    final formato = (cancion['formato'] ?? 'mp3').toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying ? const Color(0xFF7C6FF7).withOpacity(0.4) : const Color(0xFF2A2A4E).withOpacity(0.5),
          width: isPlaying ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Botón Play / Pause
            GestureDetector(
              onTap: onPlayToggle,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isPlaying ? const Color(0xFF7C6FF7) : const Color(0xFF2A2A4E),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      color: isPlaying ? const Color(0xFF7C6FF7) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detalle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Formato y duración
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formato,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duracion,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
