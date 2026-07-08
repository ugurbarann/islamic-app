import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_notification_preference.dart';
import '../../domain/repositories/prayer_notification_preference_repository.dart';

class SharedPreferencesPrayerNotificationPreferenceRepository
    implements PrayerNotificationPreferenceRepository {
  const SharedPreferencesPrayerNotificationPreferenceRepository();

  static const _preferenceKey = 'prayer_notification_preferences';
  static const _offsetMinutesKey = 'offsetMinutes';

  @override
  Future<PrayerNotificationPreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preferenceKey);
    if (jsonString == null) {
      return PrayerNotificationPreference.defaults();
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PrayerNotificationPreference(
      enabledPrayers: {
        for (final prayerName
            in PrayerNotificationPreference.configurablePrayers)
          prayerName: json[prayerName.jsonKey] as bool? ?? false,
      },
      reminderOffsetMinutes: json[_offsetMinutesKey] as int? ?? 0,
    );
  }

  @override
  Future<void> savePreference(PrayerNotificationPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _preferenceKey,
      jsonEncode({
        for (final prayerName
            in PrayerNotificationPreference.configurablePrayers)
          prayerName.jsonKey: preference.isEnabled(prayerName),
        _offsetMinutesKey: preference.reminderOffsetMinutes,
      }),
    );
  }
}
