class ApiConstants {
  // Cambia esto a la IP de tu servidor backend si pruebas en un dispositivo físico
  static const String baseUrl = 'http://192.168.1.100:8000/api'; 
  //static const String baseUrl = 'https://rbrw8r-ip-189-28-70-68.tunnelmole.net/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/usuarios/login/';
  static const String profile = '$baseUrl/usuarios/perfil/';
  
  // Product endpoints
  static const String products = '$baseUrl/productos/';
  
  // Musica endpoints
  static const String canciones = '$baseUrl/musica/canciones/';

  // Feed endpoint
  static const String feed = '$baseUrl/eventos/eventos/feed/';
}
