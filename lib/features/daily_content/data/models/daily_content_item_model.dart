import '../../domain/entities/daily_content_item.dart';
import '../../domain/entities/daily_content_type.dart';

class DailyContentItemModel {
  const DailyContentItemModel({
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

  factory DailyContentItemModel.fromJson(Map<String, dynamic> json) {
    final type = DailyContentType.fromJsonKey(json['type'] as String? ?? '');
    if (type == null) {
      throw const FormatException('Invalid daily content type');
    }

    return DailyContentItemModel(
      id: _requiredString(json, 'id'),
      type: type,
      dateKey: _requiredString(json, 'dateKey'),
      title: _requiredString(json, 'title'),
      turkishText: _requiredString(json, 'turkishText'),
      arabicText: json['arabicText'] as String?,
      turkishTransliteration: json['turkishTransliteration'] as String?,
      source: json['source'] as String?,
      category: json['category'] as String?,
      sortOrder: json['sortOrder'] as int?,
      createdAt: _optionalDate(json['createdAt'] as String?),
      updatedAt: _optionalDate(json['updatedAt'] as String?),
      validFrom: _optionalDate(json['validFrom'] as String?),
      validUntil: _optionalDate(json['validUntil'] as String?),
      reference: json['reference'] as String?,
      actionRoute: json['actionRoute'] as String?,
    );
  }

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

  DailyContentItem toEntity() {
    return switch (type) {
      DailyContentType.ayah => DailyAyah(
        id: id,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
      DailyContentType.hadith => DailyHadith(
        id: id,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
      DailyContentType.dua => DailyDua(
        id: id,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
      DailyContentType.knowledge => DailyIslamicKnowledge(
        id: id,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
      DailyContentType.surahHighlight => DailySurahHighlight(
        id: id,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
      DailyContentType.quote => DailyContentItem(
        id: id,
        type: type,
        dateKey: dateKey,
        title: title,
        turkishText: turkishText,
        arabicText: arabicText,
        turkishTransliteration: turkishTransliteration,
        source: source,
        category: category,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        validFrom: validFrom,
        validUntil: validUntil,
        reference: reference,
        actionRoute: actionRoute,
      ),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.jsonKey,
      'dateKey': dateKey,
      'title': title,
      'arabicText': arabicText,
      'turkishText': turkishText,
      'turkishTransliteration': turkishTransliteration,
      'source': source,
      'category': category,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'reference': reference,
      'actionRoute': actionRoute,
    };
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key] as String?;
    if (value == null || value.trim().isEmpty) {
      throw FormatException('Missing required field: $key');
    }
    return value;
  }

  static DateTime? _optionalDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
