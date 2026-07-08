import '../entities/daily_content_bundle.dart';
import '../entities/daily_content_metadata.dart';

abstract class DailyContentRepository {
  Future<DailyContentBundle> loadTodayContent();

  Future<DailyContentMetadata> loadMetadata();

  Future<void> clearCache();
}
