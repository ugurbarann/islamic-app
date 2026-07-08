import 'prayer_name.dart';

class NextPrayerInfo {
  const NextPrayerInfo({
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.remaining,
    this.currentPrayerName,
  });

  final PrayerName nextPrayerName;
  final DateTime nextPrayerTime;
  final Duration remaining;
  final PrayerName? currentPrayerName;
}
