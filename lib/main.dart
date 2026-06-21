import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/profile_provider.dart';
import 'presentation/state/cancion_provider.dart';
import 'presentation/state/feed_provider.dart';
import 'presentation/state/compra_provider.dart';
import 'presentation/state/notificacion_provider.dart';
import 'presentation/state/amistad_provider.dart';
import 'core/notifications/fcm_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('[Firebase] Inicialización exitosa.');
  } catch (e) {
    debugPrint('[Firebase] Error inicializando Firebase: $e');
  }

  Stripe.publishableKey =
      'pk_test_51Pabcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CancionProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => CompraProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionProvider()),
        ChangeNotifierProvider(create: (_) => AmistadProvider()),
      ],
      child: const MisterTicketApp(),
    ),
  );
}

class MisterTicketApp extends StatelessWidget {
  const MisterTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MisterTicket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
