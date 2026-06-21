import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/state/profile_provider.dart';
import '../../presentation/state/notificacion_provider.dart';

/// Inicializa servicios tras login o restauración de sesión.
Future<void> bootstrapAuthenticatedApp(BuildContext context) async {
  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  final notifProvider = Provider.of<NotificacionProvider>(context, listen: false);

  await profileProvider.loadProfile();
  await notifProvider.inicializarFCM();
  await notifProvider.cargarNotificaciones();
  await notifProvider.cargarPromotoresSeguidos();
  notifProvider.iniciarPolling();
}
