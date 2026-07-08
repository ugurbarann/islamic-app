import '../entities/prayer_time_day.dart';
import '../entities/selected_prayer_location.dart';

abstract class PrayerTimesRepository {
  Future<PrayerTimeDay> loadTodayPrayerTimes(SelectedPrayerLocation location);
}
