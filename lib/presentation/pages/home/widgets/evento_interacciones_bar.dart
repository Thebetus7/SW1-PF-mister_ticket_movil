import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/models/evento_feed.dart';
import 'package:provider/provider.dart';
import '../../../state/notificacion_provider.dart';

class EventoInteraccionesBar extends StatefulWidget {
  final EventoFeedModel evento;

  const EventoInteraccionesBar({super.key, required this.evento});

  @override
  State<EventoInteraccionesBar> createState() => _EventoInteraccionesBarState();
}

class _EventoInteraccionesBarState extends State<EventoInteraccionesBar> {
  bool _isLiked = false;
  int _likesCount = 0;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    // Generar datos ficticios basados en el ID del evento para consistencia
    final random = Random(widget.evento.id);
    _likesCount = random.nextInt(450) + 50;
    _commentsCount = random.nextInt(80) + 5;
  }

  @override
  Widget build(BuildContext context) {
    final notificacionProvider = Provider.of<NotificacionProvider>(context);
    final isSeguido = notificacionProvider.isSiguiendoPromotor(widget.evento.promotorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical perfecta
            children: [
              // Botón Me Gusta (GestureDetector para evitar padding fantasma de IconButton)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isLiked ? Colors.redAccent : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botón Comentarios
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentarios disponibles en la próxima versión'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_commentsCount',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botón Compartir
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Lógica de compartir
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Icon(
                    Icons.share_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
              
              const Spacer(),

              // Botón Seguir Promotor (Diseño Premium de Favorito / Estrella)
              GestureDetector(
                onTap: () => notificacionProvider.toggleSeguirPromotor(widget.evento.promotorId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSeguido ? const Color(0xFF7C6FF7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7C6FF7),
                      width: 1.5,
                    ),
                    boxShadow: isSeguido
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C6FF7).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSeguido ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isSeguido ? Colors.white : const Color(0xFF7C6FF7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSeguido ? 'Siguiendo' : 'Seguir',
                        style: TextStyle(
                          color: isSeguido ? Colors.white : const Color(0xFF7C6FF7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
