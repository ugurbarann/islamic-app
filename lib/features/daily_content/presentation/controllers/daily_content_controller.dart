import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/daily_content_cache_data_source.dart';
import '../../data/datasources/daily_content_remote_data_source.dart';
import '../../data/datasources/local_json_daily_content_data_source.dart';
import '../../data/repositories/default_daily_content_repository.dart';
import '../../domain/entities/daily_content_bundle.dart';
import '../../domain/entities/daily_content_metadata.dart';
import '../../domain/repositories/daily_content_repository.dart';

final dailyContentRepositoryProvider = Provider<DailyContentRepository>((ref) {
  return const DefaultDailyContentRepository(
    localDataSource: LocalJsonDailyContentDataSource(),
    cacheDataSource: DailyContentCacheDataSource(),
    remoteDataSource: FirebaseDailyContentDataSource(),
  );
});

final todayDailyContentProvider = FutureProvider<DailyContentBundle>((ref) {
  return ref.watch(dailyContentRepositoryProvider).loadTodayContent();
});

final dailyContentBootstrapProvider = FutureProvider<void>((ref) {
  return ref.watch(dailyContentRepositoryProvider).cacheUpcomingContent();
});

final dailyContentMetadataProvider = FutureProvider<DailyContentMetadata>((
  ref,
) {
  return ref.watch(dailyContentRepositoryProvider).loadMetadata();
});

final dailyContentCacheControllerProvider =
    AsyncNotifierProvider<DailyContentCacheController, void>(
      DailyContentCacheController.new,
    );

class DailyContentCacheController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> clearCache() async {
    state = const AsyncLoading();
    await ref.read(dailyContentRepositoryProvider).clearCache();
    ref.invalidate(todayDailyContentProvider);
    ref.invalidate(dailyContentMetadataProvider);
    state = const AsyncData(null);
  }
}
