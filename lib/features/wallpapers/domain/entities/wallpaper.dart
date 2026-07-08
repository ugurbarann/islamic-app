class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.localAssetPath,
    required this.colorHex,
    this.thumbnailAssetPath,
  });

  final String id;
  final String categoryId;
  final String title;
  final String localAssetPath;
  final String colorHex;
  final String? thumbnailAssetPath;
}
