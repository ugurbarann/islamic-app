import '../entities/wallpaper.dart';
import '../entities/wallpaper_category.dart';

abstract class WallpaperRepository {
  Future<List<WallpaperCategory>> loadCategories();

  Future<List<Wallpaper>> loadWallpapers();

  Future<Wallpaper> loadWallpaper(String wallpaperId);

  Future<List<String>> loadFavoriteIds();

  Future<void> addFavorite(String wallpaperId);

  Future<void> removeFavorite(String wallpaperId);
}
