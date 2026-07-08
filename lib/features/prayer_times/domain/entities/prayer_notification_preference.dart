import 'prayer_name.dart';

class PrayerNotificationPreference {
  const PrayerNotificationPreference({
    required this.enabledPrayers,
    this.reminderOffsetMinutes = 0,
  });

  factory PrayerNotificationPreference.defaults() {
    return const PrayerNotificationPreference(enabledPrayers: {});
  }

  static const configurablePrayers = [
    PrayerName.imsak,
    PrayerName.sunrise,
    PrayerName.dhuhr,
    PrayerName.asr,
    PrayerName.maghrib,
    PrayerName.isha,
  ];

  final Map<PrayerName, bool> enabledPrayers;
  final int reminderOffsetMinutes;

  static const offsetOptions = [0, 15, 30, 60];

  bool isEnabled(PrayerName prayerName) {
    return enabledPrayers[prayerName] ?? false;
  }

  bool get hasEnabledPrayer {
    return configurablePrayers.any(isEnabled);
  }

  PrayerNotificationPreference copyWithPrayer({
    required PrayerName prayerName,
    required bool enabled,
  }) {
    return PrayerNotificationPreference(
      enabledPrayers: {...enabledPrayers, prayerName: enabled},
      reminderOffsetMinutes: reminderOffsetMinutes,
    );
  }

  PrayerNotificationPreference copyWithOffset(int minutes) {
    final normalizedMinutes = offsetOptions.contains(minutes) ? minutes : 0;
    return PrayerNotificationPreference(
      enabledPrayers: enabledPrayers,
      reminderOffsetMinutes: normalizedMinutes,
    );
  }
}
