import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/wallpaper_category.dart';

class WallpaperCatalogModel {
  const WallpaperCatalogModel({
    required this.categories,
    required this.wallpapers,
  });

  factory WallpaperCatalogModel.fromJson(Map<String, dynamic> json) {
    return WallpaperCatalogModel(
      categories: (json['categories'] as List<dynamic>)
          .map((item) {
            final map = item as Map<String, dynamic>;
            return WallpaperCategory(
              id: map['id'] as String,
              title: map['title'] as String,
            );
          })
          .toList(growable: false),
      wallpapers: (json['wallpapers'] as List<dynamic>)
          .map((item) {
            final map = item as Map<String, dynamic>;
            return Wallpaper(
              id: map['id'] as String,
              categoryId: map['categoryId'] as String,
              title: map['title'] as String,
              localAssetPath: map['localAssetPath'] as String,
              colorHex: map['colorHex'] as String,
              thumbnailAssetPath: map['thumbnailAssetPath'] as String?,
            );
          })
          .toList(growable: false),
    );
  }

  final List<WallpaperCategory> categories;
  final List<Wallpaper> wallpapers;
}
