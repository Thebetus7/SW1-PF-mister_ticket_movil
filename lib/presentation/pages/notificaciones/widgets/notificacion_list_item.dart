import 'package:flutter/material.dart';
import '../../../../data/models/notificacion.dart';

class NotificacionListItem extends StatelessWidget {
  final NotificacionModel notificacion;
  final VoidCallback onTap;

  const NotificacionListItem({
    super.key,
    required this.notificacion,
    required this.onTap,
  });

  String _getTiempoTranscurrido(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  IconData _getIcon() {
    switch (notificacion.tipo) {
      case 'nuevo_evento':
        return Icons.campaign_rounded;
      case 'evento_artista':
        return Icons.music_note_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (notificacion.tipo) {
      case 'nuevo_evento':
        return const Color(0xFF7C6FF7);
      case 'evento_artista':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF3498DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notificacion.leido;
    final themeColor = _getColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread ? themeColor.withOpacity(0.3) : const Color(0xFF2A2A4E),
          width: 1,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: themeColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: themeColor.withOpacity(0.1),
            highlightColor: themeColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono circular representativo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(),
                      color: themeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Contenido de la notificación
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notificacion.titulo,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeColor.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notificacion.mensaje,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getTiempoTranscurrido(notificacion.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
