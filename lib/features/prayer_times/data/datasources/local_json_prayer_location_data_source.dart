import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/turkish_location_model.dart';

class LocalJsonPrayerLocationDataSource {
  const LocalJsonPrayerLocationDataSource({
    this.assetPath = 'assets/data/turkish_locations.json',
  });

  final String assetPath;

  Future<List<TurkishLocationModel>> loadLocations() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonList = jsonDecode(jsonString) as List<dynamic>;

    return jsonList
        .map(
          (json) => TurkishLocationModel.fromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}
