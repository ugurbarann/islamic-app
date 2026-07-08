import '../../domain/entities/daily_content_bundle.dart';
import '../../domain/entities/daily_content_metadata.dart';
import 'daily_content_item_model.dart';

class DailyContentBundleModel {
  const DailyContentBundleModel({
    required this.dateKey,
    required this.items,
    required this.metadata,
  });

  factory DailyContentBundleModel.fromJson(Map<String, dynamic> json) {
    final dateKey = json['dateKey'] as String;
    final invalidItems = <Object>[];
    final itemModels = <DailyContentItemModel>[];
    for (final itemJson in json['items'] as List<dynamic>? ?? const []) {
      try {
        itemModels.add(
          DailyContentItemModel.fromJson(itemJson as Map<String, dynamic>),
        );
      } on Object catch (error) {
        invalidItems.add(error);
      }
    }

    final metadataJson = json['metadata'] as Map<String, dynamic>? ?? const {};
    return DailyContentBundleModel(
      dateKey: dateKey,
      items: itemModels,
      metadata: DailyContentMetadata(
        source: metadataJson['source'] as String? ?? 'bundled',
        contentVersion: metadataJson['contentVersion'] as int? ?? 1,
        lastSyncAt: _optionalDate(metadataJson['lastSyncAt'] as String?),
        cachedUntil: _optionalDate(metadataJson['cachedUntil'] as String?),
        fallbackMessage: invalidItems.isEmpty
            ? metadataJson['fallbackMessage'] as String?
            : 'Bazı günlük içerikler geçersiz olduğu için atlandı.',
      ),
    );
  }

  final String dateKey;
  final List<DailyContentItemModel> items;
  final DailyContentMetadata metadata;

  DailyContentBundle toEntity() {
    final sortedItems = [...items]
      ..sort((first, second) {
        return (first.sortOrder ?? 99).compareTo(second.sortOrder ?? 99);
      });
    return DailyContentBundle(
      dateKey: dateKey,
      items: sortedItems.map((item) => item.toEntity()).toList(growable: false),
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'metadata': {
        'source': metadata.source,
        'contentVersion': metadata.contentVersion,
        'lastSyncAt': metadata.lastSyncAt?.toIso8601String(),
        'cachedUntil': metadata.cachedUntil?.toIso8601String(),
        'fallbackMessage': metadata.fallbackMessage,
      },
      'items': [for (final item in items) item.toJson()],
    };
  }

  static DateTime? _optionalDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
