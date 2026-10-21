
import 'package:animeverse/providers/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/favorite_anime_card.dart';
import '../widgets/search_field.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: context.read<AppStateProvider>().favoriteSearchQuery,
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

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Anime',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: screenWidth * 0.06,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Consumer<AppStateProvider>(
            builder: (context, provider, child) {
              return SearchField(
                controller: _searchController,
                hintText: 'Search favorites',
                onChanged: (value) {
                  provider.setFavoriteSearchQuery(value);
                },
                showClear: provider.favoriteSearchQuery.isNotEmpty,
                onClear: () {
                  _searchController.clear();
                  provider.setFavoriteSearchQuery('');
                },
              );
            },
          ),

          SizedBox(height: screenHeight * 0.01),

          // Daftar anime favorit hasil pencarian
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, favoriteProvider, child) {
                final favorites =
                    favoriteProvider.getFilteredFavorites();

                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 32,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          favoriteProvider.favorites.isEmpty
                              ? 'Belum ada anime favorit'
                              : 'Anime tidak ditemukan',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.04,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favoriteAnime = favorites[index];

                    return FavoriteAnimeCard(
                      id: favoriteAnime.id,
                      title: favoriteAnime.title,
                      genre: favoriteAnime.genre,
                      rating: favoriteAnime.rating,
                      imagePath: favoriteAnime.imagePath,
                      onTap: () {
                        context.pushNamed(
                          'detail',
                          pathParameters: {
                            'id': favoriteAnime.id,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
