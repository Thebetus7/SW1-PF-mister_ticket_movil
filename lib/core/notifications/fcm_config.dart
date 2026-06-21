import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canal Android compartido entre FCM, notificaciones locales y el backend.
const String kNotificationChannelId = 'mister_ticket_push_channel';
const String kNotificationChannelName = 'Notificaciones MisterTicket';
const String kNotificationChannelDescription =
    'Canal para las alertas de nuevos eventos y el elenco.';

const AndroidNotificationChannel kAndroidNotificationChannel =
    AndroidNotificationChannel(
  kNotificationChannelId,
  kNotificationChannelName,
  description: kNotificationChannelDescription,
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

Future<void> ensureAndroidNotificationChannel(
  FlutterLocalNotificationsPlugin plugin,
) async {
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(kAndroidNotificationChannel);
}

/// Solicita permiso POST_NOTIFICATIONS en Android 13+ (requerido en dispositivo físico).
Future<bool> requestAndroidNotificationPermission(
  FlutterLocalNotificationsPlugin plugin,
) async {
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin == null) return true;

  final granted = await androidPlugin.requestNotificationsPermission();
  return granted ?? false;
}

Future<void> showLocalNotificationBanner({
  required FlutterLocalNotificationsPlugin plugin,
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  await plugin.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        kNotificationChannelId,
        kNotificationChannelName,
        channelDescription: kNotificationChannelDescription,
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    ),
    payload: payload,
  );
}
