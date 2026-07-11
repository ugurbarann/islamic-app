import '../../domain/entities/daily_content_bundle.dart';
import '../../domain/entities/daily_content_metadata.dart';
import '../../domain/repositories/daily_content_repository.dart';
import '../datasources/daily_content_cache_data_source.dart';
import '../datasources/daily_content_remote_data_source.dart';
import '../datasources/local_json_daily_content_data_source.dart';
import '../models/daily_content_bundle_model.dart';

class DefaultDailyContentRepository implements DailyContentRepository {
  const DefaultDailyContentRepository({
    required this.localDataSource,
    required this.cacheDataSource,
    required this.remoteDataSource,
    this.cacheWindowDays = 30,
  });

  final LocalJsonDailyContentDataSource localDataSource;
  final DailyContentCacheDataSource cacheDataSource;
  final DailyContentRemoteDataSource remoteDataSource;
  final int cacheWindowDays;

  @override
  Future<DailyContentBundle> loadTodayContent() async {
    final now = DateTime.now();
    final today = _dateKey(now);
    final cached = await _refreshUpcomingCache(now);
    if (cached.isNotEmpty) {
      final cachedToday =
          _findByDate(cached, today) ?? _bestAvailable(cached, today);
      if (cachedToday != null) {
        return _withFallbackMessageIfNeeded(cachedToday, today).toEntity();
      }
    }

    final local = await localDataSource.loadBundles();
    final localToday =
        _findByDate(local, today) ?? _bestAvailable(local, today);
    if (localToday != null) {
      return _withFallbackMessageIfNeeded(localToday, today).toEntity();
    }

    throw StateError('Günlük içerik bulunamadı.');
  }

  @override
  Future<void> cacheUpcomingContent() async {
    await _refreshUpcomingCache(DateTime.now());
  }

  @override
  Future<DailyContentMetadata> loadMetadata() async {
    final cacheMetadata = await cacheDataSource.loadMetadata();
    if (cacheMetadata != null) {
      return cacheMetadata;
    }
    final cached = await cacheDataSource.loadBundles();
    if (cached.isEmpty) {
      return const DailyContentMetadata(source: 'bundled', contentVersion: 1);
    }
    return cached.last.metadata;
  }

  @override
  Future<void> clearCache() {
    return cacheDataSource.clear();
  }

  Future<List<DailyContentBundleModel>> _refreshUpcomingCache(
    DateTime now,
  ) async {
    final today = _dateKey(now);
    final windowEnd = _dateKey(now.add(Duration(days: cacheWindowDays - 1)));
    final cached = await cacheDataSource.loadBundles();
    try {
      final remote = await remoteDataSource.loadWindow(
        startDateKey: today,
        endDateKey: windowEnd,
      );
      if (remote.isEmpty) {
        return _upcomingWindow(cached, today, windowEnd);
      }
      final merged = <String, DailyContentBundleModel>{
        for (final bundle in cached) bundle.dateKey: bundle,
        for (final bundle in remote) bundle.dateKey: bundle,
      };
      final upcoming = _upcomingWindow(
        merged.values.toList(growable: false),
        today,
        windowEnd,
      );
      if (upcoming.isNotEmpty) {
        await cacheDataSource.saveBundles(upcoming);
      }
      return upcoming;
    } on Object {
      return _upcomingWindow(cached, today, windowEnd);
    }
  }

  List<DailyContentBundleModel> _upcomingWindow(
    List<DailyContentBundleModel> bundles,
    String startDateKey,
    String endDateKey,
  ) {
    final sorted =
        bundles
            .where(
              (bundle) =>
                  bundle.dateKey.compareTo(startDateKey) >= 0 &&
                  bundle.dateKey.compareTo(endDateKey) <= 0,
            )
            .toList()
          ..sort((first, second) {
            return first.dateKey.compareTo(second.dateKey);
          });
    if (sorted.length <= cacheWindowDays) {
      return sorted;
    }
    return sorted.sublist(0, cacheWindowDays);
  }

  DailyContentBundleModel? _findByDate(
    List<DailyContentBundleModel> bundles,
    String dateKey,
  ) {
    for (final bundle in bundles) {
      if (bundle.dateKey == dateKey) {
        return bundle;
      }
    }
    return null;
  }

  DailyContentBundleModel? _bestAvailable(
    List<DailyContentBundleModel> bundles,
    String today,
  ) {
    if (bundles.isEmpty) {
      return null;
    }
    final sorted = [...bundles]
      ..sort((first, second) {
        return first.dateKey.compareTo(second.dateKey);
      });
    final notAfterToday = sorted
        .where((bundle) => bundle.dateKey.compareTo(today) <= 0)
        .toList(growable: false);
    return notAfterToday.isNotEmpty ? notAfterToday.last : sorted.first;
  }

  DailyContentBundleModel _withFallbackMessageIfNeeded(
    DailyContentBundleModel bundle,
    String today,
  ) {
    if (bundle.dateKey == today) {
      return bundle;
    }
    return DailyContentBundleModel(
      dateKey: bundle.dateKey,
      items: bundle.items,
      metadata: bundle.metadata.copyWith(
        fallbackMessage:
            'Bugünün içeriği henüz güncellenmedi. Kayıtlı içerik gösteriliyor.',
      ),
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
