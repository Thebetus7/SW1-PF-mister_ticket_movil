class ApiConstants {
  // Se obtiene de variables de entorno al compilar con: flutter run --dart-define=API_URL=http://<IP>:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.1.100:8000/api',
  );
  
  // Auth endpoints
  static const String login = '$baseUrl/usuarios/login/';
  static const String profile = '$baseUrl/usuarios/perfil/';
  
  // Musica endpoints
  static const String canciones = '$baseUrl/musica/canciones/';

  // Feed endpoint
  static const String feed = '$baseUrl/eventos/eventos/feed/';

  // Compra y Tickets endpoints
  static String zonasEvento(int eventoId) => '$baseUrl/eventos/eventos/$eventoId/zonas-disponibles/';
  static const String comprar = '$baseUrl/tickets/comprar/';
  static const String misTickets = '$baseUrl/tickets/tickets/mis-tickets/';
}

