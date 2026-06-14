import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/feed_provider.dart';
import 'evento_feed_card.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  @override
  void initState() {
    super.initState();
    // Cargar el feed al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading && feedProvider.feed.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C6FF7)),
              ),
            );
          }

          if (feedProvider.error != null && feedProvider.feed.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar el feed',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedProvider.error!,
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6FF7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => feedProvider.loadFeed(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (feedProvider.feed.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => feedProvider.loadFeed(),
              color: const Color(0xFF7C6FF7),
              backgroundColor: const Color(0xFF1A1A2E),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_off_rounded, color: Colors.white.withOpacity(0.15), size: 80),
                            const SizedBox(height: 16),
                            const Text(
                              'El escenario está vacío',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Aún no hay conciertos publicados. Vuelve a consultar más tarde.',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => feedProvider.loadFeed(),
            color: const Color(0xFF7C6FF7),
            backgroundColor: const Color(0xFF1A1A2E),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedProvider.feed.length,
              itemBuilder: (context, index) {
                final evento = feedProvider.feed[index];
                return EventoFeedCard(evento: evento);
              },
            ),
          );
        },
      ),
    );
  }
}
