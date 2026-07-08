import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/daily_content_bundle_model.dart';

abstract class DailyContentRemoteDataSource {
  Future<List<DailyContentBundleModel>> loadWindow({
    required String startDateKey,
    required String endDateKey,
  });
}

class FirebaseDailyContentDataSource implements DailyContentRemoteDataSource {
  const FirebaseDailyContentDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<List<DailyContentBundleModel>> loadWindow({
    required String startDateKey,
    required String endDateKey,
  }) async {
    final snapshot = await _db
        .collection('daily_content')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateKey)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endDateKey)
        .orderBy(FieldPath.documentId)
        .get();

    final bundles = <DailyContentBundleModel>[];
    for (final document in snapshot.docs) {
      final bundle = _bundleFromDocument(document);
      if (bundle != null && bundle.items.isNotEmpty) {
        bundles.add(bundle);
      }
    }
    return bundles;
  }

  DailyContentBundleModel? _bundleFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    try {
      final json = _normalizeMap(document.data());
      json['dateKey'] = json['dateKey'] as String? ?? document.id;
      json['metadata'] =
          json['metadata'] as Map<String, dynamic>? ??
          {'source': 'firebase', 'contentVersion': 1};
      json['items'] = json['items'] as List<dynamic>? ?? const [];
      return DailyContentBundleModel.fromJson(json);
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> value) {
    return {
      for (final entry in value.entries)
        entry.key: _normalizeValue(entry.value),
    };
  }

  Object? _normalizeValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      final normalized = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is String) {
          normalized[key] = _normalizeValue(entry.value);
        }
      }
      return normalized;
    }
    if (value is Iterable) {
      return [for (final item in value) _normalizeValue(item)];
    }
    return value;
  }
}
