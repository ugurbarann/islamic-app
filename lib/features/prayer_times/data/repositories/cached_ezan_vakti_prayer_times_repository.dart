import '../../domain/entities/prayer_time_day.dart';
import '../../domain/entities/selected_prayer_location.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/ezan_vakti_remote_data_source.dart';
import '../datasources/prayer_times_cache_data_source.dart';
import '../models/ezan_vakti_prayer_day_model.dart';
import 'local_mock_prayer_times_repository.dart';

class CachedEzanVaktiPrayerTimesRepository implements PrayerTimesRepository {
  const CachedEzanVaktiPrayerTimesRepository({
    required this.remoteDataSource,
    required this.cacheDataSource,
    required this.fallbackRepository,
  });

  final EzanVaktiRemoteDataSource remoteDataSource;
  final PrayerTimesCacheDataSource cacheDataSource;
  final LocalMockPrayerTimesRepository fallbackRepository;

  @override
  Future<PrayerTimeDay> loadTodayPrayerTimes(
    SelectedPrayerLocation location,
  ) async {
    final districtId = location.district.ezanVaktiDistrictId;
    if (districtId == null) {
      return fallbackRepository.loadTodayPrayerTimes(location);
    }

    final today = _today();
    final cachedDays = await cacheDataSource.loadPrayerTimes(districtId);
    final cachedToday = _findDay(cachedDays, today);
    if (cachedToday != null) {
      return cachedToday.toEntity(location);
    }

    try {
      final remoteDays = await remoteDataSource.loadPrayerTimes(districtId);
      await cacheDataSource.savePrayerTimes(
        districtId: districtId,
        days: remoteDays,
      );
      final remoteToday = _findDay(remoteDays, today);
      if (remoteToday != null) {
        return remoteToday.toEntity(location);
      }
    } on Object {
      final fallbackCachedDays = await cacheDataSource.loadPrayerTimes(
        districtId,
      );
      final fallbackCachedToday = _findDay(fallbackCachedDays, today);
      if (fallbackCachedToday != null) {
        return fallbackCachedToday.toEntity(location);
      }
    }

    return fallbackRepository.loadTodayPrayerTimes(location);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  EzanVaktiPrayerDayModel? _findDay(
    List<EzanVaktiPrayerDayModel>? days,
    DateTime date,
  ) {
    if (days == null || days.isEmpty) {
      return null;
    }

    for (final day in days) {
      if (day.matchesDate(date)) {
        return day;
      }
    }
    return null;
  }
}
