import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/daily_content_bundle_model.dart';

class LocalJsonDailyContentDataSource {
  const LocalJsonDailyContentDataSource({
    this.assetPath = 'assets/data/daily_content_sample.json',
  });

  static final Map<String, Future<List<DailyContentBundleModel>>> _cache = {};

  final String assetPath;

  Future<List<DailyContentBundleModel>> loadBundles() {
    return _cache.putIfAbsent(assetPath, _loadBundles);
  }

  Future<List<DailyContentBundleModel>> _loadBundles() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final bundlesJson = jsonMap['bundles'] as List<dynamic>? ?? const [];
    return bundlesJson
        .map(
          (json) =>
              DailyContentBundleModel.fromJson(json as Map<String, dynamic>),
        )
        .where((bundle) => bundle.items.isNotEmpty)
        .toList(growable: false);
  }
}
