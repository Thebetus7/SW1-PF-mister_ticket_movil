import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/profile_provider.dart';
import '../../state/cancion_provider.dart';
import 'widgets/cancion_list_item.dart';
import 'widgets/reproductor_flotante.dart';

class MiMusicaPage extends StatefulWidget {
  const MiMusicaPage({super.key});

  @override
  State<MiMusicaPage> createState() => _MiMusicaPageState();
}

class _MiMusicaPageState extends State<MiMusicaPage> {
  Map<String, dynamic>? _cancionActiva;
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios del perfil para reaccionar cuando termine de cargarse en segundo plano
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    if (profileProvider.profileData != null && !_initialized) {
      if (profileProvider.esArtista) {
        _initialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<CancionProvider>(context, listen: false).loadCanciones();
        });
      }
    }
  }

  void _reproducirCancion(Map<String, dynamic> cancion) {
    setState(() {
      if (_cancionActiva != null && _cancionActiva!['id'] == cancion['id']) {
        // Si ya está sonando la misma, detenemos/play
        _isPlaying = !_isPlaying;
        if (!_isPlaying) {
          _cancionActiva = null;
        }
      } else {
        _cancionActiva = cancion;
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileProvider, CancionProvider>(
      builder: (context, profileProvider, cancionProvider, _) {
        final esArtista = profileProvider.esArtista;

        if (!esArtista) {
          return _buildFanView();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Cabecera e instrucciones CRUD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mi Música',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gestiona e importa tu catálogo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón Añadir música
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-musica');
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'Añadir',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C6FF7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lista de Canciones
                    Expanded(
                      child: cancionProvider.isLoading
                          ? _buildLoadingState()
                          : cancionProvider.canciones.isEmpty
                              ? _buildEmptyState()
                              : _buildCancionesList(cancionProvider),
                    ),
                  ],
                ),
              ),

              // Reproductor flotante persistente en la parte inferior si hay canción activa
              if (_cancionActiva != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ReproductorFlotante(
                    cancion: _cancionActiva!,
                    audioUrl: cancionProvider.fixLocalhostUrl(_cancionActiva!['archivo_url']),
                    onFinished: () {
                      setState(() {
                        _isPlaying = false;
                        _cancionActiva = null;
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Vista vacía/placeholder para fans
  Widget _buildFanView() {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_rounded,
                color: Colors.white24,
                size: 72,
              ),
              SizedBox(height: 16),
              Text(
                'Mi Música',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Esta sección está en desarrollo para fans. ¡Pronto podrás ver tu biblioteca personal!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            color: Colors.white.withOpacity(0.15),
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no has compartido música',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '¡Sube tu primer tema musical para empezar!',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCancionesList(CancionProvider provider) {
    return ListView.builder(
      itemCount: provider.canciones.length,
      physics: const BouncingScrollPhysics(),
      // Dejar padding en la parte inferior para que el reproductor flotante no tape el último item
      padding: EdgeInsets.only(bottom: _cancionActiva != null ? 150 : 20),
      itemBuilder: (context, index) {
        final cancion = provider.canciones[index];
        final id = cancion['id'];
        final isPlaying = _cancionActiva != null && _cancionActiva!['id'] == id && _isPlaying;

        return CancionListItem(
          cancion: cancion,
          isPlaying: isPlaying,
          onPlayToggle: () => _reproducirCancion(cancion),
          onDelete: () async {
            final success = await provider.deleteCancion(id);
            if (success) {
              if (_cancionActiva != null && _cancionActiva!['id'] == id) {
                setState(() {
                  _cancionActiva = null;
                  _isPlaying = false;
                });
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Canción eliminada correctamente'),
                    backgroundColor: const Color(0xFF2ECC71),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Error al eliminar la canción'),
                    backgroundColor: const Color(0xFFE74C3C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}
