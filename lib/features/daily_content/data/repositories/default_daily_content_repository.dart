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
    final today = _dateKey(DateTime.now());
    final windowStart = _dateKey(
      DateTime.now().subtract(Duration(days: cacheWindowDays ~/ 2)),
    );
    final windowEnd = _dateKey(
      DateTime.now().add(Duration(days: cacheWindowDays ~/ 2)),
    );

    List<DailyContentBundleModel> remoteBundles = const [];
    try {
      remoteBundles = await remoteDataSource.loadWindow(
        startDateKey: windowStart,
        endDateKey: windowEnd,
      );
    } on Object {
      remoteBundles = const [];
    }
    if (remoteBundles.isNotEmpty) {
      final cleaned = _cleanup(remoteBundles);
      await cacheDataSource.saveBundles(cleaned);
      final remoteToday = _findByDate(cleaned, today) ?? _latest(cleaned);
      if (remoteToday != null) {
        return _withFallbackMessageIfNeeded(remoteToday, today).toEntity();
      }
    }

    final cached = _cleanup(await cacheDataSource.loadBundles());
    if (cached.isNotEmpty) {
      await cacheDataSource.saveBundles(cached);
      final cachedToday = _findByDate(cached, today) ?? _latest(cached);
      if (cachedToday != null) {
        return _withFallbackMessageIfNeeded(cachedToday, today).toEntity();
      }
    }

    final local = await localDataSource.loadBundles();
    final localToday = _findByDate(local, today) ?? _latest(local);
    if (localToday != null) {
      return _withFallbackMessageIfNeeded(localToday, today).toEntity();
    }

    throw StateError('Günlük içerik bulunamadı.');
  }

  @override
  Future<DailyContentMetadata> loadMetadata() async {
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

  List<DailyContentBundleModel> _cleanup(
    List<DailyContentBundleModel> bundles,
  ) {
    final sorted = [...bundles]
      ..sort((first, second) {
        return first.dateKey.compareTo(second.dateKey);
      });
    if (sorted.length <= cacheWindowDays) {
      return sorted;
    }
    return sorted.sublist(sorted.length - cacheWindowDays);
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

  DailyContentBundleModel? _latest(List<DailyContentBundleModel> bundles) {
    if (bundles.isEmpty) {
      return null;
    }
    final sorted = [...bundles]
      ..sort((first, second) {
        return first.dateKey.compareTo(second.dateKey);
      });
    return sorted.last;
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
