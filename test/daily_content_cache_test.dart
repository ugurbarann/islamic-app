import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/daily_content/data/datasources/daily_content_cache_data_source.dart';
import 'package:islamic_app/features/daily_content/data/datasources/daily_content_remote_data_source.dart';
import 'package:islamic_app/features/daily_content/data/datasources/local_json_daily_content_data_source.dart';
import 'package:islamic_app/features/daily_content/data/models/daily_content_bundle_model.dart';
import 'package:islamic_app/features/daily_content/data/models/daily_content_item_model.dart';
import 'package:islamic_app/features/daily_content/data/repositories/default_daily_content_repository.dart';
import 'package:islamic_app/features/daily_content/domain/entities/daily_content_metadata.dart';
import 'package:islamic_app/features/daily_content/domain/entities/daily_content_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('caches today and the next 29 days for offline use', () async {
    SharedPreferences.setMockInitialValues({});
    const cache = DailyContentCacheDataSource();
    final today = DateTime.now();
    final remote = _FakeDailyContentRemoteDataSource(
      List.generate(30, (index) => _bundle(today.add(Duration(days: index)))),
    );
    final repository = DefaultDailyContentRepository(
      localDataSource: const LocalJsonDailyContentDataSource(),
      cacheDataSource: cache,
      remoteDataSource: remote,
    );

    await repository.cacheUpcomingContent();

    final cached = await cache.loadBundles();
    expect(cached, hasLength(30));
    expect(cached.first.dateKey, _dateKey(today));
    expect(cached.last.dateKey, _dateKey(today.add(const Duration(days: 29))));
    expect(remote.lastStartDateKey, _dateKey(today));
    expect(
      remote.lastEndDateKey,
      _dateKey(today.add(const Duration(days: 29))),
    );

    remote.shouldFail = true;
    final offlineToday = await repository.loadTodayContent();
    expect(offlineToday.dateKey, _dateKey(today));
    expect(offlineToday.items.single.turkishText, 'Doğrulanmış içerik');
  });
}

class _FakeDailyContentRemoteDataSource
    implements DailyContentRemoteDataSource {
  _FakeDailyContentRemoteDataSource(this.bundles);

  final List<DailyContentBundleModel> bundles;
  bool shouldFail = false;
  String? lastStartDateKey;
  String? lastEndDateKey;

  @override
  Future<List<DailyContentBundleModel>> loadWindow({
    required String startDateKey,
    required String endDateKey,
  }) async {
    lastStartDateKey = startDateKey;
    lastEndDateKey = endDateKey;
    if (shouldFail) {
      throw StateError('offline');
    }
    return bundles;
  }
}

DailyContentBundleModel _bundle(DateTime date) {
  final dateKey = _dateKey(date);
  return DailyContentBundleModel(
    dateKey: dateKey,
    metadata: DailyContentMetadata(
      source: 'firebase-test',
      contentVersion: 3,
      cachedUntil: date,
    ),
    items: [
      DailyContentItemModel(
        id: '${dateKey}_knowledge',
        type: DailyContentType.knowledge,
        dateKey: dateKey,
        title: 'Günün Bilgisi',
        turkishText: 'Doğrulanmış içerik',
      ),
    ],
  );
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
