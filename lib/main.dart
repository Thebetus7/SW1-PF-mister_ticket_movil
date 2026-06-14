import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/profile_provider.dart';
import 'presentation/state/cancion_provider.dart';
import 'presentation/state/feed_provider.dart';
import 'presentation/state/compra_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Stripe (modo test / académico)
  Stripe.publishableKey = 'pk_test_51Pabcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CancionProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => CompraProvider()),
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
