import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ezan_vakti_district_model.dart';
import '../models/ezan_vakti_prayer_day_model.dart';

class PrayerTimesCacheDataSource {
  const PrayerTimesCacheDataSource();

  static const _districtsPrefix = 'ezan_vakti_districts_v1';
  static const _prayerTimesPrefix = 'ezan_vakti_prayer_times_v1';

  Future<List<EzanVaktiDistrictModel>?> loadDistricts(String cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString('$_districtsPrefix.$cityId');
    if (rawValue == null) {
      return null;
    }

    final jsonList = jsonDecode(rawValue) as List<dynamic>;
    return jsonList
        .map(
          (json) =>
              EzanVaktiDistrictModel.fromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<void> saveDistricts({
    required String cityId,
    required List<EzanVaktiDistrictModel> districts,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_districtsPrefix.$cityId',
      jsonEncode([
        for (final district in districts)
          {
            'IlceAdi': district.name,
            'IlceAdiEn': district.nameEn,
            'IlceID': district.id,
          },
      ]),
    );
  }

  Future<List<EzanVaktiPrayerDayModel>?> loadPrayerTimes(
    String districtId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString('$_prayerTimesPrefix.$districtId');
    if (rawValue == null) {
      return null;
    }

    final jsonMap = jsonDecode(rawValue) as Map<String, dynamic>;
    final daysJson = jsonMap['days'] as List<dynamic>;
    return daysJson
        .map(
          (json) => EzanVaktiPrayerDayModel.fromCacheJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }

  Future<void> savePrayerTimes({
    required String districtId,
    required List<EzanVaktiPrayerDayModel> days,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prayerTimesPrefix.$districtId',
      jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'days': [for (final day in days) day.toCacheJson()],
      }),
    );
  }
}
