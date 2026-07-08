import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_content_bundle_model.dart';

class DailyContentCacheDataSource {
  const DailyContentCacheDataSource();

  static const _cacheKey = 'daily_content_cache_v1';
  static const _metadataKey = 'daily_content_cache_metadata_v1';

  Future<List<DailyContentBundleModel>> loadBundles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString == null) {
      return const [];
    }
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (json) =>
              DailyContentBundleModel.fromJson(json as Map<String, dynamic>),
        )
        .where((bundle) => bundle.items.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> saveBundles(List<DailyContentBundleModel> bundles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode([for (final bundle in bundles) bundle.toJson()]),
    );
    await prefs.setString(
      _metadataKey,
      jsonEncode({
        'lastSyncAt': DateTime.now().toIso8601String(),
        'contentVersion': bundles.isEmpty
            ? 1
            : bundles
                  .map((bundle) => bundle.metadata.contentVersion)
                  .reduce((first, second) => first > second ? first : second),
        'source': 'cache',
        'cachedUntil': bundles.isEmpty ? null : bundles.last.dateKey,
      }),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_metadataKey);
  }
}
