import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../state/profile_provider.dart';
import 'notificaciones/notificaciones_page.dart';
import 'notificaciones/pages/detalle_evento_notificacion_page.dart';
import 'home/home_feed_page.dart';
import 'tickets/mis_tickets_page.dart';
import 'musica/mi_musica_page.dart';
import 'perfil/perfil_page.dart';
import '../state/notificacion_provider.dart';
import '../../config/routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final notifProvider = Provider.of<NotificacionProvider>(context, listen: false);
      notifProvider.cargarNotificaciones(silent: true);
      notifProvider.refrescarTokenFCM();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _selectedIndex = args;
      }
      _initialized = true;
    }
  }

  Future<void> _logout() async {
    Provider.of<NotificacionProvider>(context, listen: false).resetOnLogout();
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacionProvider = Provider.of<NotificacionProvider>(context);
    if (notificacionProvider.routeEventId != null) {
      final int evId = notificacionProvider.routeEventId!;
      notificacionProvider.clearRouteEventId();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleEventoNotificacionPage(eventoId: evId),
          ),
        );
      });
    }

    final profileProvider = Provider.of<ProfileProvider>(context);
    final isFan = profileProvider.roles.contains('fan');
    final nombreUsuario = (profileProvider.nombreCompleto != null &&
            profileProvider.nombreCompleto!.isNotEmpty)
        ? profileProvider.nombreCompleto!
        : profileProvider.username;

    final List<Widget> pages = [];
    final List<BottomNavigationBarItem> navBarItems = [];

    if (isFan) {
      pages.addAll([
        const HomeFeedPage(),
        const NotificacionesPage(),
        const MisTicketsPage(),
        const MiMusicaPage(),
        const PerfilPage(),
      ]);
      navBarItems.addAll(const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_rounded),
          activeIcon: Icon(Icons.notifications_rounded),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number_outlined),
          activeIcon: Icon(Icons.confirmation_number_rounded),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music_rounded),
          label: 'Mi Música',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Yo',
        ),
      ]);
    } else {
      pages.addAll([
        const HomeFeedPage(),
        const NotificacionesPage(),
        const MiMusicaPage(),
        const PerfilPage(),
      ]);
      navBarItems.addAll(const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_rounded),
          activeIcon: Icon(Icons.notifications_rounded),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music_rounded),
          label: 'Mi Música',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Yo',
        ),
      ]);
    }

    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFF1A1A2E),
              title: Row(
                children: [
                  const Text(
                    'MisterTicket',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (nombreUsuario.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          nombreUsuario,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  tooltip: 'Cerrar sesión',
                  onPressed: _logout,
                )
              ],
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1A1A2E),
          selectedItemColor: const Color(0xFF7C6FF7),
          unselectedItemColor: Colors.white30,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: navBarItems,
        ),
      ),
    );
  }
}
