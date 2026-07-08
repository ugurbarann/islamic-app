import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/wallpaper_category.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/local_json_wallpaper_data_source.dart';

class LocalWallpaperRepository implements WallpaperRepository {
  const LocalWallpaperRepository({required this.dataSource});

  static const _favoritesKey = 'favorite_wallpapers';

  final LocalJsonWallpaperDataSource dataSource;

  @override
  Future<List<WallpaperCategory>> loadCategories() async {
    final catalog = await dataSource.loadCatalog();
    return catalog.categories;
  }

  @override
  Future<List<Wallpaper>> loadWallpapers() async {
    final catalog = await dataSource.loadCatalog();
    return catalog.wallpapers;
  }

  @override
  Future<Wallpaper> loadWallpaper(String wallpaperId) async {
    final wallpapers = await loadWallpapers();
    return wallpapers.firstWhere((wallpaper) => wallpaper.id == wallpaperId);
  }

  @override
  Future<List<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) {
      return const [];
    }
    return (jsonDecode(jsonString) as List<dynamic>).cast<String>();
  }

  @override
  Future<void> addFavorite(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavoriteIds();
    await prefs.setString(
      _favoritesKey,
      jsonEncode({...favorites, wallpaperId}.toList()),
    );
  }

  @override
  Future<void> removeFavorite(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavoriteIds();
    await prefs.setString(
      _favoritesKey,
      jsonEncode(
        favorites.where((favoriteId) => favoriteId != wallpaperId).toList(),
      ),
    );
  }
}
