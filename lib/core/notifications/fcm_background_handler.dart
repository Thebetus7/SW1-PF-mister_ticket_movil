import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_config.dart';

/// Handler para mensajes FCM con la app en background o terminada.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Mensaje en background: ${message.notification?.title ?? message.data}');

  final FlutterLocalNotificationsPlugin localPlugin =
      FlutterLocalNotificationsPlugin();
  await ensureAndroidNotificationChannel(localPlugin);

  final RemoteNotification? notification = message.notification;
  final String title = notification?.title ??
      message.data['title']?.toString() ??
      'Nueva notificación';
  final String body = notification?.body ??
      message.data['body']?.toString() ??
      message.data['mensaje']?.toString() ??
      '';

  if (title.isEmpty && body.isEmpty) return;

  await showLocalNotificationBanner(
    plugin: localPlugin,
    id: message.hashCode,
    title: title,
    body: body,
    payload: message.data['evento_id']?.toString(),
  );
}
