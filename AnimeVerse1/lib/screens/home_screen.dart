
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/anime_view.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/genre_list.dart';
import '../widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: context.read<AppStateProvider>().homeSearchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        final filteredAnime = provider.getFilteredAnimeForHome();

        return AppScaffold(
          appBar: AppBar(
            title: Text(
              'AnimeVerse',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: screenWidth * 0.075,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search Bar
                SearchField(
                  controller: _searchController,
                  hintText: 'Anime Title',
                  onChanged: (value) {
                    provider.setHomeSearchQuery(value);
                  },
                  showClear: provider.homeSearchQuery.isNotEmpty,
                  onClear: () {
                    _searchController.clear();
                    provider.setHomeSearchQuery('');
                  },
                ),

                // Filter genre
                GenreList(
                  selected: provider.selectedGenre,
                  onGenreSelected: (genre) {
                    provider.setSelectedGenre(genre);
                  },
                ),

                SizedBox(height: screenHeight * 0.03),

                // Daftar anime hasil filter
                if (filteredAnime.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.04,
                    ),
                    child: const Center(
                      child: Text(
                        'Anime tidak ditemukan',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                else
                  AnimeView(animeList: filteredAnime),

                SizedBox(height: screenHeight * 0.025),
              ],
            ),
          ),
        );
      },
    );
  }
}
