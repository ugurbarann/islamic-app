import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/local_wallpaper_device_service.dart';
import '../../../../core/platform/wallpaper_device_service.dart';
import '../../data/datasources/local_json_wallpaper_data_source.dart';
import '../../data/repositories/local_wallpaper_repository.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/entities/wallpaper_category.dart';
import '../../domain/repositories/wallpaper_repository.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return const LocalWallpaperRepository(
    dataSource: LocalJsonWallpaperDataSource(),
  );
});

final wallpaperDeviceServiceProvider = Provider<WallpaperDeviceService>((ref) {
  return const LocalWallpaperDeviceService();
});

final wallpaperCategoriesProvider = FutureProvider<List<WallpaperCategory>>((
  ref,
) {
  return ref.watch(wallpaperRepositoryProvider).loadCategories();
});

final wallpapersProvider = FutureProvider<List<Wallpaper>>((ref) {
  return ref.watch(wallpaperRepositoryProvider).loadWallpapers();
});

final wallpaperDetailProvider = FutureProvider.family<Wallpaper, String>((
  ref,
  wallpaperId,
) {
  return ref.watch(wallpaperRepositoryProvider).loadWallpaper(wallpaperId);
});

final favoriteWallpapersControllerProvider =
    AsyncNotifierProvider<FavoriteWallpapersController, List<String>>(
      FavoriteWallpapersController.new,
    );

class FavoriteWallpapersController extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() {
    return ref.watch(wallpaperRepositoryProvider).loadFavoriteIds();
  }

  Future<void> toggleFavorite(String wallpaperId) async {
    final repository = ref.read(wallpaperRepositoryProvider);
    final favorites = await repository.loadFavoriteIds();
    if (favorites.contains(wallpaperId)) {
      await repository.removeFavorite(wallpaperId);
    } else {
      await repository.addFavorite(wallpaperId);
    }
    state = AsyncData(await repository.loadFavoriteIds());
  }
}

final wallpaperDeviceActionControllerProvider =
    AsyncNotifierProvider<
      WallpaperDeviceActionController,
      WallpaperDeviceActionResult?
    >(WallpaperDeviceActionController.new);

class WallpaperDeviceActionController
    extends AsyncNotifier<WallpaperDeviceActionResult?> {
  @override
  Future<WallpaperDeviceActionResult?> build() async {
    return null;
  }

  Future<WallpaperDeviceActionResult> download(Wallpaper wallpaper) async {
    state = const AsyncLoading();
    final result = await ref
        .read(wallpaperDeviceServiceProvider)
        .saveToAppStorage(
          assetPath: wallpaper.localAssetPath,
          fileName: wallpaper.id,
        );
    state = AsyncData(result);
    return result;
  }

  Future<WallpaperDeviceActionResult> share(Wallpaper wallpaper) async {
    state = const AsyncLoading();
    final result = await ref
        .read(wallpaperDeviceServiceProvider)
        .shareWallpaper(
          assetPath: wallpaper.localAssetPath,
          title: wallpaper.title,
        );
    state = AsyncData(result);
    return result;
  }

  Future<WallpaperDeviceActionResult> setAsWallpaper(
    Wallpaper wallpaper,
    WallpaperTarget target,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(wallpaperDeviceServiceProvider)
        .setAsWallpaper(
          assetPath: wallpaper.localAssetPath,
          title: wallpaper.title,
          target: target,
        );
    state = AsyncData(result);
    return result;
  }
}
