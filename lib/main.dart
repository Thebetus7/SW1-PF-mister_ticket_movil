import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/product_provider.dart';
import 'presentation/state/profile_provider.dart';
import 'presentation/state/cancion_provider.dart';
import 'presentation/state/feed_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CancionProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
    );
  }
}
