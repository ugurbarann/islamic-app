import '../../domain/entities/prayer_time_day.dart';
import '../../domain/entities/selected_prayer_location.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/local_json_prayer_times_data_source.dart';

class LocalMockPrayerTimesRepository implements PrayerTimesRepository {
  const LocalMockPrayerTimesRepository({required this.dataSource});

  final LocalJsonPrayerTimesDataSource dataSource;

  @override
  Future<PrayerTimeDay> loadTodayPrayerTimes(
    SelectedPrayerLocation location,
  ) async {
    final today = DateTime.now();
    final timeStrings = await dataSource.loadTimes(
      cityId: location.city.id,
      districtId: location.district.id,
    );

    return PrayerTimeDay(
      date: DateTime(today.year, today.month, today.day),
      location: location,
      times: {
        for (final entry in timeStrings.entries)
          entry.key: _parseTimeForDate(today, entry.value),
      },
    );
  }

  DateTime _parseTimeForDate(DateTime date, String value) {
    final parts = value.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts.first),
      int.parse(parts.last),
    );
  }
}
