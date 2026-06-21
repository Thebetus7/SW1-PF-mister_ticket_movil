import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/notificacion_provider.dart';
import 'widgets/notificacion_list_item.dart';
import 'pages/detalle_evento_notificacion_page.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  @override
  void initState() {
    super.initState();
    // Forzar la recarga al entrar a la pantalla de notificaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificacionProvider>(context, listen: false).cargarNotificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificacionProvider = Provider.of<NotificacionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (notificacionProvider.unreadCount > 0)
                  TextButton(
                    onPressed: () => notificacionProvider.marcarTodasLeidas(),
                    child: const Text(
                      'Leer todo',
                      style: TextStyle(
                        color: Color(0xFF7C6FF7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF7C6FF7),
                backgroundColor: const Color(0xFF1E1E2E),
                onRefresh: () => notificacionProvider.cargarNotificaciones(),
                child: notificacionProvider.isLoading && notificacionProvider.notificaciones.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6FF7)))
                    : notificacionProvider.notificaciones.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: notificacionProvider.notificaciones.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final notif = notificacionProvider.notificaciones[index];

                              return Dismissible(
                                key: Key(notif.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE74C3C),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  // Llamar a eliminar en el servidor
                                  notificacionProvider.eliminarNotificacion(notif.id);
                                  
                                  // Mostrar SnackBar de aviso
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Notificación eliminada',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: const Color(0xFFE74C3C),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                child: NotificacionListItem(
                                  notificacion: notif,
                                  onTap: () {
                                    // Marcar como leída en local/servidor
                                    notificacionProvider.marcarLeida(notif.id);
                                    
                                    // Si está asociada a un evento, ir al detalle
                                    if (notif.eventoId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetalleEventoNotificacionPage(
                                            eventoId: notif.eventoId!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A2A4E)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 50,
              color: Colors.white30,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Te avisaremos cuando haya noticias importantes sobre tus artistas o eventos favoritos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
