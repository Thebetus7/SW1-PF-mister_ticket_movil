class ApiConstants {
  // === CONFIGURACIÓN DE LA IP DEL BACKEND ===
  //
  // 1. Web / Computadora Local (PC Run):
  //    - Usa: 'http://localhost:8000/api' o 'http://127.0.0.1:8000/api'
  //
  // 2. Emulador de Android (AVD):
  //    - Usa: 'http://10.0.2.2:8000/api' (Redirección especial del emulador al localhost de la PC)
  //
  // 3. Emulador de iOS (Simulador Mac):
  //    - Usa: 'http://localhost:8000/api' (Comparte la red con la Mac directamente)
  //
  // 4. Dispositivo Móvil Físico (Android/iOS conectado a la misma red WiFi):
  //    - Usa la IP local de tu computadora en la red WiFi.
  //    - Ejemplo: 'http://192.168.1.100:8000/api' (Verifica tu IP con 'ipconfig' en Windows o 'ifconfig' en macOS)
  //
  // Se obtiene de variables de entorno al compilar con:
  // flutter run --dart-define=API_URL=http://<IP>:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.100:8000/api',
  );

  // Auth endpoints
  static const String login = '$baseUrl/usuarios/login/';
  static const String profile = '$baseUrl/usuarios/perfil/';
  static const String tokenRefresh = '$baseUrl/usuarios/token/refresh/';

  // Notificaciones & Dispositivos
  static const String notificaciones = '$baseUrl/usuarios/notificaciones/';
  static const String registrarDispositivo = '$baseUrl/usuarios/dispositivos/registrar/';

  // Seguimiento Promotores
  static const String promotores = '$baseUrl/usuarios/promotores/';

  // Musica endpoints
  static const String canciones = '$baseUrl/musica/canciones/';

  // Feed endpoint
  static const String feed = '$baseUrl/eventos/eventos/feed/';

  // Compra y Tickets endpoints
  static String zonasEvento(int eventoId) =>
      '$baseUrl/eventos/eventos/$eventoId/zonas-disponibles/';
  static const String comprar = '$baseUrl/tickets/comprar/';
  static const String misTickets = '$baseUrl/tickets/tickets/mis-tickets/';
  static const String verificarQr = '$baseUrl/tickets/tickets/verificar-qr/';
  static String transferirTicket(int ticketId) =>
      '$baseUrl/tickets/tickets/$ticketId/transferir/';

  // Verificador
  static const String misRegistros = '$baseUrl/eventos/registros-acceso/mis-registros/';

  // Amistades
  static const String amistades = '$baseUrl/usuarios/amistades/';
  static const String misAmigos = '${amistades}mis-amigos/';
  static const String solicitudesAmistad = '${amistades}solicitudes/';
  static const String solicitarAmistad = '${amistades}solicitar/';
  static String aceptarAmistad(int id) => '${amistades}$id/aceptar/';
  static String rechazarAmistad(int id) => '${amistades}$id/rechazar/';
  static const String listaUsuarios = '$baseUrl/usuarios/lista/';
  static const String fansUsuarios = '${listaUsuarios}fans/';
}
