import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/evento_feed.dart';
import '../../../state/cancion_provider.dart';
import 'artista_detalles_modal.dart';

class EventoElencoSeccion extends StatelessWidget {
  final EventoFeedModel evento;
  final List<PresentacionFeedModel> presentaciones;

  const EventoElencoSeccion({
    super.key,
    required this.evento,
    required this.presentaciones,
  });

  String _formatHora(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _mostrarDetallesArtistaModal(
    BuildContext context,
    ArtistaFeedModel artista,
    PresentacionFeedModel pres,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ArtistaDetallesModalWidget(
          artista: artista,
          evento: evento,
          pres: pres,
          formatHoraFn: _formatHora,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (presentaciones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            'ELENCO DEL SHOW',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        // Corrección de Overflow: Aumentamos la altura de 95 a 105 para dar suficiente espacio al nuevo contador
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: presentaciones.length,
            itemBuilder: (context, index) {
              final pres = presentaciones[index];
              final art = pres.artista;
              if (art == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  _mostrarDetallesArtistaModal(context, art, pres);
                },
                child: Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 12, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          art.nombreArtistico,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Fila inferior con Popularidad y Cantidad de Música
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${art.popularidad}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<List<dynamic>>(
                            future: Provider.of<CancionProvider>(context, listen: false)
                                .loadCancionesDeArtista(art.id),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.length ?? 0;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.music_note_rounded,
                                    color: Color(0xFF7C6FF7),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
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
      ],
    );
  }
}
