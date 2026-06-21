import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/models/notificacion.dart';
import '../../data/repositories/notificacion_repository.dart';
import '../../core/notifications/fcm_config.dart';

/// Proveedor de estado global para notificaciones y seguimiento de promotores.
/// Integra Firebase Cloud Messaging (FCM) y notificaciones locales.
class NotificacionProvider extends ChangeNotifier {
  final NotificacionRepository _repository = NotificacionRepository();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<NotificacionModel> _notificaciones = [];
  List<int> _promotoresSeguidos = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _fcmInitialized = false;
  Timer? _pollingTimer;
  final Set<int> _knownNotificationIds = {};

  int? _routeEventId;

  List<NotificacionModel> get notificaciones => _notificaciones;
  List<int> get promotoresSeguidos => _promotoresSeguidos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get routeEventId => _routeEventId;

  int get unreadCount => _notificaciones.where((n) => !n.leido).length;

  /// Inicializa FCM y notificaciones locales (solo una vez por sesión).
  Future<void> inicializarFCM() async {
    if (_fcmInitialized) {
      await _registrarTokenActual();
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          if (details.payload != null) {
            try {
              _routeEventId = int.parse(details.payload!);
              notifyListeners();
            } catch (_) {}
          }
        },
      );

      await ensureAndroidNotificationChannel(_localNotificationsPlugin);

      final bool notificationsGranted = await requestAndroidNotificationPermission(
        _localNotificationsPlugin,
      );
      debugPrint('[FCM] Permiso Android POST_NOTIFICATIONS: $notificationsGranted');

      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Estado de permisos: ${settings.authorizationStatus}');

      await _registrarTokenActual();

      FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
        debugPrint('[FCM] Token actualizado: $newToken');
        registrarToken(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '[FCM] Mensaje recibido en Foreground: ${message.notification?.title ?? message.data}',
        );
        _mostrarAlertaLocal(message);
        cargarNotificaciones(silent: true);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] Mensaje abierto por el usuario: ${message.data}');
        _handleNotificationData(message.data);
        cargarNotificaciones(silent: true);
      });

      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] App abierta desde notificación terminada');
        _handleNotificationData(initialMessage.data);
      }

      _fcmInitialized = true;
    } catch (e) {
      debugPrint('[FCM] Error inicializando Firebase: $e');
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final String? evIdStr = data['evento_id']?.toString();
    if (evIdStr != null) {
      try {
        _routeEventId = int.parse(evIdStr);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _registrarTokenActual() async {
    final String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint('[FCM] Token obtenido: $token');
      await registrarToken(token);
    }
  }

  /// Re-registra el token FCM (p. ej. al volver a primer plano).
  Future<void> refrescarTokenFCM() async {
    await _registrarTokenActual();
  }

  void clearRouteEventId() {
    _routeEventId = null;
  }

  Future<void> registrarToken(String token) async {
    try {
      await _repository.registrarFCMToken(token);
      debugPrint('[FCM] Token registrado correctamente en el servidor.');
    } catch (e) {
      debugPrint('[FCM] Error registrando token en servidor: $e');
    }
  }

  Future<void> _mostrarAlertaLocal(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final String title = notification?.title ??
        message.data['title']?.toString() ??
        'Nueva notificación';
    final String body = notification?.body ??
        message.data['body']?.toString() ??
        message.data['mensaje']?.toString() ??
        '';
    final String? evIdStr = message.data['evento_id']?.toString();

    if (title.isEmpty && body.isEmpty) return;

    await showLocalNotificationBanner(
      plugin: _localNotificationsPlugin,
      id: message.hashCode,
      title: title,
      body: body,
      payload: evIdStr,
    );
  }

  /// Polling de respaldo para actualizar el buzón con la app en primer plano.
  void iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      cargarNotificaciones(silent: true);
    });
  }

  void detenerPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Limpia estado al cerrar sesión.
  void resetOnLogout() {
    detenerPolling();
    _fcmInitialized = false;
    _knownNotificationIds.clear();
    _notificaciones = [];
    _promotoresSeguidos = [];
    _routeEventId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarNotificaciones({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final nuevas = await _repository.getNotificaciones();
      final nuevasIds = nuevas.map((n) => n.id).toSet();
      final recienLlegadas = nuevas.where(
        (n) => !_knownNotificationIds.contains(n.id),
      );

      if (silent && _knownNotificationIds.isNotEmpty) {
        for (final notif in recienLlegadas) {
          await showLocalNotificationBanner(
            plugin: _localNotificationsPlugin,
            id: notif.id,
            title: notif.titulo,
            body: notif.mensaje,
            payload: notif.eventoId?.toString(),
          );
        }
      }

      _knownNotificationIds
        ..clear()
        ..addAll(nuevasIds);
      _notificaciones = nuevas;
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> marcarLeida(int id) async {
    try {
      final success = await _repository.marcarLeida(id);
      if (success) {
        final idx = _notificaciones.indexWhere((n) => n.id == id);
        if (idx != -1) {
          _notificaciones[idx] = NotificacionModel(
            id: _notificaciones[idx].id,
            titulo: _notificaciones[idx].titulo,
            mensaje: _notificaciones[idx].mensaje,
            tipo: _notificaciones[idx].tipo,
            leido: true,
            eventoId: _notificaciones[idx].eventoId,
            eventoNombre: _notificaciones[idx].eventoNombre,
            createdAt: _notificaciones[idx].createdAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[Notificación] Error al marcar leída: $e');
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      final success = await _repository.marcarTodasLeidas();
      if (success) {
        _notificaciones = _notificaciones
            .map((n) => NotificacionModel(
                  id: n.id,
                  titulo: n.titulo,
                  mensaje: n.mensaje,
                  tipo: n.tipo,
                  leido: true,
                  eventoId: n.eventoId,
                  eventoNombre: n.eventoNombre,
                  createdAt: n.createdAt,
                ))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Notificación] Error marcar todas leídas: $e');
    }
  }

  Future<bool> eliminarNotificacion(int id) async {
    try {
      final success = await _repository.eliminarNotificacion(id);
      if (success) {
        _notificaciones.removeWhere((n) => n.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[Notificación] Error eliminando alerta: $e');
      return false;
    }
  }

  Future<void> cargarPromotoresSeguidos() async {
    try {
      _promotoresSeguidos = await _repository.getPromotoresSeguidos();
      notifyListeners();
    } catch (e) {
      debugPrint('[Seguimiento] Error cargando promotores seguidos: $e');
    }
  }

  bool isSiguiendoPromotor(int promotorId) {
    return _promotoresSeguidos.contains(promotorId);
  }

  Future<void> toggleSeguirPromotor(int promotorId) async {
    try {
      final siguiendo = await _repository.seguirPromotor(promotorId);
      if (siguiendo) {
        if (!_promotoresSeguidos.contains(promotorId)) {
          _promotoresSeguidos.add(promotorId);
        }
      } else {
        _promotoresSeguidos.remove(promotorId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[Seguimiento] Error al alternar seguimiento: $e');
    }
  }

  Future<Map<String, dynamic>> cargarEventoDetalle(int id) async {
    return await _repository.getEventoDetalle(id);
  }

  @override
  void dispose() {
    detenerPolling();
    super.dispose();
  }
}
