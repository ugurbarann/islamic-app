class WallpaperDeviceActionResult {
  const WallpaperDeviceActionResult({
    required this.success,
    required this.message,
    this.savedPath,
  });

  final bool success;
  final String message;
  final String? savedPath;
}

enum WallpaperTarget {
  home,
  lock,
  both;

  String get platformValue {
    return switch (this) {
      WallpaperTarget.home => 'home',
      WallpaperTarget.lock => 'lock',
      WallpaperTarget.both => 'both',
    };
  }

  String get successMessage {
    return switch (this) {
      WallpaperTarget.home => 'Duvar kağıdı ana ekrana uygulandı.',
      WallpaperTarget.lock => 'Duvar kağıdı kilit ekranına uygulandı.',
      WallpaperTarget.both =>
        'Duvar kağıdı ana ekran ve kilit ekranına uygulandı.',
    };
  }
}

abstract class WallpaperDeviceService {
  Future<WallpaperDeviceActionResult> saveToAppStorage({
    required String assetPath,
    required String fileName,
  });

  Future<WallpaperDeviceActionResult> shareWallpaper({
    required String assetPath,
    required String title,
  });

  Future<WallpaperDeviceActionResult> setAsWallpaper({
    required String assetPath,
    required String title,
    required WallpaperTarget target,
  });
}
