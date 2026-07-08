import '../entities/next_prayer_info.dart';
import '../entities/prayer_name.dart';
import '../entities/prayer_time_day.dart';

class CalculateNextPrayerInfo {
  const CalculateNextPrayerInfo();

  NextPrayerInfo call(PrayerTimeDay prayerTimeDay, DateTime now) {
    PrayerName? currentPrayerName;

    for (final prayerName in PrayerName.values) {
      final prayerTime = prayerTimeDay.timeFor(prayerName);
      if (now.isBefore(prayerTime)) {
        return NextPrayerInfo(
          nextPrayerName: prayerName,
          nextPrayerTime: prayerTime,
          remaining: prayerTime.difference(now),
          currentPrayerName: currentPrayerName,
        );
      }
      currentPrayerName = prayerName;
    }

    final tomorrowImsak = prayerTimeDay
        .timeFor(PrayerName.imsak)
        .add(const Duration(days: 1));

    return NextPrayerInfo(
      nextPrayerName: PrayerName.imsak,
      nextPrayerTime: tomorrowImsak,
      remaining: tomorrowImsak.difference(now),
      currentPrayerName: PrayerName.isha,
    );
  }
}
