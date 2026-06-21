import 'package:flutter/material.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/perfil/perfil_page.dart';
import '../presentation/pages/musica/add_musica_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String perfil = '/perfil';
  static const String addMusica = '/add-musica';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashPage(),
      login: (context) => const LoginPage(),
      dashboard: (context) => const DashboardPage(),
      perfil: (context) => const PerfilPage(),
      addMusica: (context) => const AddMusicaPage(),
    };
  }
}
