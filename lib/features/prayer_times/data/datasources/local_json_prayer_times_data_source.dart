import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/prayer_name.dart';

class LocalJsonPrayerTimesDataSource {
  const LocalJsonPrayerTimesDataSource({
    this.assetPath = 'assets/data/mock_prayer_times.json',
  });

  final String assetPath;

  Future<Map<PrayerName, String>> loadTimes({
    required String cityId,
    required String districtId,
  }) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonList = jsonDecode(jsonString) as List<dynamic>;

    final items = jsonList.cast<Map<String, dynamic>>();
    final item = items.firstWhere((entry) {
      final districtIds = (entry['districtIds'] as List<dynamic>)
          .cast<String>();
      return entry['cityId'] == cityId && districtIds.contains(districtId);
    }, orElse: () => items.first);

    final timesJson = item['times'] as Map<String, dynamic>;
    return {
      for (final prayerName in PrayerName.values)
        prayerName: timesJson[prayerName.jsonKey] as String,
    };
  }
}
