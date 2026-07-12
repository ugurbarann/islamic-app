import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ezan_vakti_remote_data_source.dart';
import '../../data/datasources/prayer_times_cache_data_source.dart';
import '../../data/repositories/cached_ezan_vakti_prayer_times_repository.dart';
import '../../domain/entities/next_prayer_info.dart';
import '../../domain/entities/prayer_time_day.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../../domain/usecases/calculate_next_prayer_info.dart';
import 'prayer_location_controller.dart';

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  return CachedEzanVaktiPrayerTimesRepository(
    remoteDataSource: EzanVaktiRemoteDataSource(),
    cacheDataSource: const PrayerTimesCacheDataSource(),
  );
});

final todayPrayerTimesProvider = FutureProvider<PrayerTimeDay>((ref) async {
  final location = await ref.watch(
    selectedPrayerLocationControllerProvider.future,
  );

  return ref
      .watch(prayerTimesRepositoryProvider)
      .loadTodayPrayerTimes(location);
});

final calculateNextPrayerInfoProvider = Provider<CalculateNextPrayerInfo>((
  ref,
) {
  return const CalculateNextPrayerInfo();
});

final nextPrayerInfoProvider = StreamProvider<NextPrayerInfo>((ref) async* {
  final prayerTimeDay = await ref.watch(todayPrayerTimesProvider.future);
  final calculateNextPrayerInfo = ref.watch(calculateNextPrayerInfoProvider);

  while (true) {
    yield calculateNextPrayerInfo(prayerTimeDay, DateTime.now());
    await Future<void>.delayed(const Duration(seconds: 1));
  }
});
