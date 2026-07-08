import 'prayer_name.dart';
import 'selected_prayer_location.dart';

class PrayerTimeDay {
  const PrayerTimeDay({
    required this.date,
    required this.location,
    required this.times,
  });

  final DateTime date;
  final SelectedPrayerLocation location;
  final Map<PrayerName, DateTime> times;

  DateTime timeFor(PrayerName prayerName) => times[prayerName]!;
}
