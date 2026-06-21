import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/feed_provider.dart';
import '../../state/cancion_provider.dart';
import '../../../data/models/evento_feed.dart';
import 'evento_feed_card.dart';
import 'widgets/evento_filtro_bar.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  String _searchQuery = '';
  String? _selectedGenre;
  final Map<int, int> _artistSongCounts = {};
  bool _loadingSongsCount = false;

  @override
  void initState() {
    super.initState();
    // Cargar el feed al iniciar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).loadFeed();
    });
  }

  /// Carga de forma asíncrona la cantidad de canciones que ha publicado cada artista
  /// en el feed de eventos actual para poder aplicar el filtro de "artista con al menos una canción".
  Future<void> _loadSongsCountForFeed(List<EventoFeedModel> events) async {
    if (_loadingSongsCount) return;
    _loadingSongsCount = true;

    // Obtener los IDs únicos de artistas
    final uniqueArtistIds = events
        .expand((e) => e.presentaciones)
        .map((p) => p.artista)
        .whereType<ArtistaFeedModel>()
        .map((a) => a.id)
        .toSet();

    final cancionProvider = Provider.of<CancionProvider>(context, listen: false);
    for (final id in uniqueArtistIds) {
      if (!_artistSongCounts.containsKey(id)) {
        try {
          final songs = await cancionProvider.loadCancionesDeArtista(id);
          if (mounted) {
            setState(() {
              _artistSongCounts[id] = songs.length;
            });
          }
        } catch (_) {}
      }
    }
    _loadingSongsCount = false;
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

          // Disparar carga de conteo de canciones para los artistas del feed en segundo plano
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadSongsCountForFeed(feedProvider.feed);
          });

          // Obtener géneros musicales únicos de los artistas disponibles en el feed
          final availableGenres = feedProvider.feed
              .expand((e) => e.presentaciones)
              .map((p) => p.artista)
              .whereType<ArtistaFeedModel>()
              .expand((a) => a.generosMusicalesNombres)
              .toSet()
              .toList();

          // Filtrar el feed localmente
          final filteredFeed = feedProvider.feed.where((evento) {
            // Filtro por búsqueda de artista
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final hasMatchingArtist = evento.presentaciones.any((pres) {
                final art = pres.artista;
                if (art == null) return false;
                
                final matchesName = art.nombreArtistico.toLowerCase().contains(query);
                // Si aún no hemos cargado su contador, le permitimos pasar inicialmente,
                // de lo contrario verificamos que tenga al menos una canción compartida (> 0)
                final songCount = _artistSongCounts[art.id];
                final hasSongs = songCount == null || songCount > 0;

                return matchesName && hasSongs;
              });
              if (!hasMatchingArtist) return false;
            }

            // Filtro por género musical
            if (_selectedGenre != null) {
              final hasMatchingGenre = evento.presentaciones.any((pres) {
                final art = pres.artista;
                if (art == null) return false;
                return art.generosMusicalesNombres.contains(_selectedGenre);
              });
              if (!hasMatchingGenre) return false;
            }

            return true;
          }).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return Column(
            children: [
              // Barra de filtros
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: EventoFiltroBar(
                  searchQuery: _searchQuery,
                  selectedGenre: _selectedGenre,
                  genres: availableGenres,
                  onSearchChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  onGenreChanged: (val) {
                    setState(() {
                      _selectedGenre = val;
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedGenre = null;
                    });
                  },
                ),
              ),
              
              // Feed de eventos
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => feedProvider.loadFeed(),
                  color: const Color(0xFF7C6FF7),
                  backgroundColor: const Color(0xFF1A1A2E),
                  child: filteredFeed.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        color: Colors.white.withOpacity(0.15),
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Sin resultados',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Ningún concierto coincide con los filtros aplicados.',
                                        style: TextStyle(color: Colors.white54, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredFeed.length,
                          itemBuilder: (context, index) {
                            final evento = filteredFeed[index];
                            return EventoFeedCard(evento: evento);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
