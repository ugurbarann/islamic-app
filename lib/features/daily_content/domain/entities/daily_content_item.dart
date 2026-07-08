import 'daily_content_type.dart';

class DailyContentItem {
  const DailyContentItem({
    required this.id,
    required this.type,
    required this.dateKey,
    required this.title,
    required this.turkishText,
    this.arabicText,
    this.turkishTransliteration,
    this.source,
    this.category,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.validFrom,
    this.validUntil,
    this.reference,
    this.actionRoute,
  });

  final String id;
  final DailyContentType type;
  final String dateKey;
  final String title;
  final String? arabicText;
  final String turkishText;
  final String? turkishTransliteration;
  final String? source;
  final String? category;
  final int? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? reference;
  final String? actionRoute;
}

class DailyAyah extends DailyContentItem {
  const DailyAyah({
    required super.id,
    required super.dateKey,
    required super.title,
    required super.turkishText,
    super.arabicText,
    super.turkishTransliteration,
    super.source,
    super.category,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    super.validFrom,
    super.validUntil,
    super.reference,
    super.actionRoute,
  }) : super(type: DailyContentType.ayah);
}

class DailyHadith extends DailyContentItem {
  const DailyHadith({
    required super.id,
    required super.dateKey,
    required super.title,
    required super.turkishText,
    super.arabicText,
    super.turkishTransliteration,
    super.source,
    super.category,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    super.validFrom,
    super.validUntil,
    super.reference,
    super.actionRoute,
  }) : super(type: DailyContentType.hadith);
}

class DailyDua extends DailyContentItem {
  const DailyDua({
    required super.id,
    required super.dateKey,
    required super.title,
    required super.turkishText,
    super.arabicText,
    super.turkishTransliteration,
    super.source,
    super.category,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    super.validFrom,
    super.validUntil,
    super.reference,
    super.actionRoute,
  }) : super(type: DailyContentType.dua);
}

class DailyIslamicKnowledge extends DailyContentItem {
  const DailyIslamicKnowledge({
    required super.id,
    required super.dateKey,
    required super.title,
    required super.turkishText,
    super.arabicText,
    super.turkishTransliteration,
    super.source,
    super.category,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    super.validFrom,
    super.validUntil,
    super.reference,
    super.actionRoute,
  }) : super(type: DailyContentType.knowledge);
}

class DailySurahHighlight extends DailyContentItem {
  const DailySurahHighlight({
    required super.id,
    required super.dateKey,
    required super.title,
    required super.turkishText,
    super.arabicText,
    super.turkishTransliteration,
    super.source,
    super.category,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    super.validFrom,
    super.validUntil,
    super.reference,
    super.actionRoute,
  }) : super(type: DailyContentType.surahHighlight);
}
