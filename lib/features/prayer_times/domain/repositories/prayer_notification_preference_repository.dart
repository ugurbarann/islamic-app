import '../entities/prayer_notification_preference.dart';

abstract class PrayerNotificationPreferenceRepository {
  Future<PrayerNotificationPreference> loadPreference();

  Future<void> savePreference(PrayerNotificationPreference preference);
}
