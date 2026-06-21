import 'package:flutter/material.dart';

class CancionListItem extends StatelessWidget {
  final Map<String, dynamic> cancion;
  final bool isPlaying;
  final VoidCallback onPlayToggle;
  final VoidCallback onDelete;
  final VoidCallback? onPublishToggle;

  const CancionListItem({
    super.key,
    required this.cancion,
    required this.isPlaying,
    required this.onPlayToggle,
    required this.onDelete,
    this.onPublishToggle,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = cancion['nombre'] ?? 'Sin título';
    final detalle = cancion['detalle'] ?? '';
    final duracion = cancion['duracion_formateada'] ?? '0:00';
    final tamano = cancion['tamano_formateado'] ?? '0 KB';
    final formato = (cancion['formato'] ?? 'mp3').toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? const Color(0xFF7C6FF7).withOpacity(0.5) : const Color(0xFF2A2A4E),
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          if (isPlaying)
            BoxShadow(
              color: const Color(0xFF7C6FF7).withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Contenedor del disco/icono musical con gradiente
              GestureDetector(
                onTap: onPlayToggle,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: isPlaying
                          ? [const Color(0xFF7C6FF7), const Color(0xFFE74C3C)]
                          : [const Color(0xFF2A2A4E), const Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Información del audio y metadatos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        color: isPlaying ? const Color(0xFF7C6FF7) : Colors.white,
                        fontSize: 16,
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
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // Fila de metadatos/atributos
                    Row(
                      children: [
                        _buildMetaBadge(formato, const Color(0xFFE74C3C)),
                        const SizedBox(width: 6),
                        _buildMetaBadge(tamano, const Color(0xFF3498DB)),
                        if (onPublishToggle != null) ...[
                          const SizedBox(width: 6),
                          _buildPublishBadge(cancion['publicado'] ?? false, onPublishToggle!),
                        ],
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: Colors.white.withOpacity(0.4),
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              duracion,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 20,
                ),
                onPressed: () {
                  _showDeleteConfirmDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPublishBadge(bool publicado, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: publicado ? const Color(0xFF2ECC71).withOpacity(0.12) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: publicado ? const Color(0xFF2ECC71).withOpacity(0.4) : Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              publicado ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: publicado ? const Color(0xFF2ECC71) : Colors.white60,
              size: 10,
            ),
            const SizedBox(width: 4),
            Text(
              publicado ? 'PUBLICADO' : 'NO PUBLICADO',
              style: TextStyle(
                color: publicado ? const Color(0xFF2ECC71) : Colors.white60,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Eliminar canción',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Está seguro de que desea eliminar la canción "${cancion['nombre']}"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
