import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quran_sample_model.dart';

class LocalJsonQuranDataSource {
  const LocalJsonQuranDataSource({
    this.indexAssetPath = 'assets/data/quran_index.json',
    this.surahAssetDirectory = 'assets/data/quran_surahs',
  });

  static final Map<String, Future<List<QuranSurahIndexModel>>> _indexCache = {};
  static final Map<String, Future<QuranSampleModel>> _surahCache = {};

  final String indexAssetPath;
  final String surahAssetDirectory;

  Future<List<QuranSurahIndexModel>> loadSurahIndex() async {
    return _indexCache.putIfAbsent(indexAssetPath, _loadSurahIndex);
  }

  Future<QuranSampleModel> loadSurahData(int surahNumber) async {
    final assetPath =
        '$surahAssetDirectory/${surahNumber.toString().padLeft(3, '0')}.json';
    return _surahCache.putIfAbsent(assetPath, () => _loadSurahData(assetPath));
  }

  Future<List<QuranSampleModel>> loadAllSurahData() async {
    final index = await loadSurahIndex();
    final result = <QuranSampleModel>[];
    for (final surah in index) {
      result.add(await loadSurahData(surah.surah.number));
    }
    return result;
  }

  Future<List<QuranSurahIndexModel>> _loadSurahIndex() async {
    final jsonString = await rootBundle.loadString(indexAssetPath);
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (json) => QuranSurahIndexModel.fromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<QuranSampleModel> _loadSurahData(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuranSampleModel.fromJson(json);
  }
}
