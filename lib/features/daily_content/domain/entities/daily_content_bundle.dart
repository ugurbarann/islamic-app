import 'daily_content_item.dart';
import 'daily_content_metadata.dart';
import 'daily_content_type.dart';

class DailyContentBundle {
  const DailyContentBundle({
    required this.dateKey,
    required this.items,
    required this.metadata,
  });

  final String dateKey;
  final List<DailyContentItem> items;
  final DailyContentMetadata metadata;

  DailyContentItem? itemOfType(DailyContentType type) {
    for (final item in items) {
      if (item.type == type) {
        return item;
      }
    }
    return null;
  }

  DailyContentItem? get ayah => itemOfType(DailyContentType.ayah);

  DailyContentItem? get hadith => itemOfType(DailyContentType.hadith);

  DailyContentItem? get dua => itemOfType(DailyContentType.dua);

  DailyContentItem? get knowledge => itemOfType(DailyContentType.knowledge);

  DailyContentItem? get quote => itemOfType(DailyContentType.quote);

  DailyContentItem? get surahHighlight =>
      itemOfType(DailyContentType.surahHighlight);
}
