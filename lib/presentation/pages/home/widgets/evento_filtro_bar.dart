import 'package:flutter/material.dart';

class EventoFiltroBar extends StatelessWidget {
  final String searchQuery;
  final String? selectedGenre;
  final List<String> genres;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onGenreChanged;
  final VoidCallback onClear;

  const EventoFiltroBar({
    super.key,
    required this.searchQuery,
    required this.selectedGenre,
    required this.genres,
    required this.onSearchChanged,
    required this.onGenreChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final isFilterActive = searchQuery.isNotEmpty || selectedGenre != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda por artista
          TextField(
            onChanged: onSearchChanged,
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: searchQuery.length),
              ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar por artista con música...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4), size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.white.withOpacity(0.6), size: 18),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F0F1A),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeColor.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Selector de género y Limpiar filtros
          Row(
            children: [
              // Selector de género (Dropdown)
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F1A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGenre,
                      hint: Text(
                        'Todos los géneros',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      dropdownColor: const Color(0xFF1A1A2E),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'Todos los géneros',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ...genres.map((g) => DropdownMenuItem<String>(
                              value: g,
                              child: Text(
                                g,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )),
                      ],
                      onChanged: onGenreChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botón Limpiar filtros (solo si hay filtros activos)
              if (isFilterActive)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C6FF7), Color(0xFF5A4FCF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list_off_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Limpiar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
