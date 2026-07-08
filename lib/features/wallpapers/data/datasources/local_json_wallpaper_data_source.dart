import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/wallpaper_catalog_model.dart';

class LocalJsonWallpaperDataSource {
  const LocalJsonWallpaperDataSource({
    this.assetPath = 'assets/data/wallpapers_sample.json',
  });

  final String assetPath;

  Future<WallpaperCatalogModel> loadCatalog() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return WallpaperCatalogModel.fromJson(json);
  }
}
