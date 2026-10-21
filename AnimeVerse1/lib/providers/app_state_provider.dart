
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/anime.dart';
import '../data/dummy_data.dart';

class AppStateProvider extends ChangeNotifier {
  final List<Anime> _favorites = [];

  static const String _storageKey = 'favorite_anime_list';

  String _selectedGenre = 'All';
  String _homeSearchQuery = '';
  String _favoriteSearchQuery = '';

  AppStateProvider() {
    _loadFavorites();
  }

  // Getter daftar favorit
  List<Anime> get favorites => List.unmodifiable(_favorites);

  // Getter dan setter genre terpilih
  String get selectedGenre => _selectedGenre;

  void setSelectedGenre(String genre) {
    if (_selectedGenre == genre) return;

    _selectedGenre = genre;
    notifyListeners();
  }

  // Getter dan setter pencarian Home
  String get homeSearchQuery => _homeSearchQuery;

  void setHomeSearchQuery(String query) {
    if (_homeSearchQuery == query) return;

    _homeSearchQuery = query;
    notifyListeners();
  }

  // Getter dan setter pencarian Favorites
  String get favoriteSearchQuery => _favoriteSearchQuery;

  void setFavoriteSearchQuery(String query) {
    if (_favoriteSearchQuery == query) return;

    _favoriteSearchQuery = query;
    notifyListeners();
  }

  // Memeriksa apakah anime sudah menjadi favorit
  bool isFavorite(String id) {
    return _favorites.any((anime) => anime.id == id);
  }

  // Menambahkan atau menghapus anime dari favorit
  void toggleFavorite(Anime anime) {
    if (isFavorite(anime.id)) {
      removeFavorite(anime);
    } else {
      addFavorite(anime);
    }
  }

  // Menghapus anime dari favorit
  void removeFavorite(Anime anime) {
    _favorites.removeWhere((item) => item.id == anime.id);
    _saveFavorites();
    notifyListeners();
  }

  // Memfilter anime berdasarkan genre
  List<Anime> getFilteredAnimeForHome() {
    List<Anime> result = DummyData.animeList;

    if (_selectedGenre != 'All') {
      result = result.where((anime) {
        final genres = anime.genre
            .split(',')
            .map((genre) => genre.trim().toLowerCase())
            .toList();

        return genres.contains(_selectedGenre.toLowerCase());
      }).toList();
    }

    // Filter judul berdasarkan pencarian Home
    if (_homeSearchQuery.trim().isNotEmpty) {
      final query = _homeSearchQuery.trim().toLowerCase();

      result = result.where((anime) {
        return anime.title.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  // Memfilter daftar favorit berdasarkan pencarian Favorites
  List<Anime> getFilteredFavorites() {
    if (_favoriteSearchQuery.trim().isEmpty) {
      return List<Anime>.from(_favorites);
    }

    final query = _favoriteSearchQuery.trim().toLowerCase();

    return _favorites.where((anime) {
      return anime.title.toLowerCase().contains(query);
    }).toList();
  }

  // Menambahkan anime ke favorit
  void addFavorite(Anime anime) {
    if (!isFavorite(anime.id)) {
      _favorites.add(anime);
      _saveFavorites();
      notifyListeners();
    }
  }

  // Menyimpan daftar favorit ke SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> favoritesJson = _favorites
          .map((anime) => anime.toJson())
          .toList();

      await prefs.setString(
        _storageKey,
        jsonEncode(favoritesJson),
      );
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Memuat daftar favorit saat aplikasi dibuka
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedFavorites = prefs.getString(_storageKey);

      if (savedFavorites != null) {
        final List<dynamic> decodedFavorites =
            jsonDecode(savedFavorites) as List<dynamic>;

        _favorites
          ..clear()
          ..addAll(
            decodedFavorites.map(
              (item) => Anime.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
          );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }
}
