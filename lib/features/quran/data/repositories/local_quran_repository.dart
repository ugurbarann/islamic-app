import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ayah.dart';
import '../../domain/entities/ayah_bookmark.dart';
import '../../domain/entities/last_read_position.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/local_json_quran_data_source.dart';

class LocalQuranRepository implements QuranRepository {
  const LocalQuranRepository({required this.dataSource});

  static const _bookmarksKey = 'quran_bookmarks';
  static const _lastReadKey = 'quran_last_read';

  final LocalJsonQuranDataSource dataSource;

  @override
  Future<List<Surah>> loadSurahs() async {
    final data = await dataSource.loadSurahIndex();
    return data.map((item) => item.surah).toList(growable: false);
  }

  @override
  Future<Surah> loadSurah(int surahNumber) async {
    final data = await dataSource.loadSurahData(surahNumber);
    return data.surah;
  }

  @override
  Future<List<Ayah>> loadAyahs(int surahNumber) async {
    final data = await dataSource.loadSurahData(surahNumber);
    return data.ayahs;
  }

  @override
  Future<Ayah> loadAyah({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final ayahs = await loadAyahs(surahNumber);
    return ayahs.firstWhere((ayah) => ayah.ayahNumber == ayahNumber);
  }

  @override
  Future<List<AyahBookmark>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookmarksKey);
    if (jsonString == null) {
      return const [];
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) {
          final map = json as Map<String, dynamic>;
          return AyahBookmark(
            ayahId: map['ayahId'] as String,
            createdAt: DateTime.parse(map['createdAt'] as String),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<Ayah>> loadBookmarkedAyahs() async {
    final bookmarks = await loadBookmarks();
    final ayahs = <Ayah>[];

    for (final bookmark in bookmarks) {
      final parts = bookmark.ayahId.split(':');
      ayahs.add(
        await loadAyah(
          surahNumber: int.parse(parts.first),
          ayahNumber: int.parse(parts.last),
        ),
      );
    }

    return ayahs;
  }

  @override
  Future<void> saveBookmark(AyahBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await loadBookmarks();
    final withoutDuplicate = bookmarks
        .where((item) => item.ayahId != bookmark.ayahId)
        .toList();

    await prefs.setString(
      _bookmarksKey,
      jsonEncode([
        ...withoutDuplicate.map(_bookmarkToJson),
        _bookmarkToJson(bookmark),
      ]),
    );
  }

  @override
  Future<void> removeBookmark(String ayahId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await loadBookmarks();
    await prefs.setString(
      _bookmarksKey,
      jsonEncode(
        bookmarks
            .where((bookmark) => bookmark.ayahId != ayahId)
            .map(_bookmarkToJson)
            .toList(),
      ),
    );
  }

  @override
  Future<LastReadPosition?> loadLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastReadKey);
    if (jsonString == null) {
      return null;
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return LastReadPosition(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  Future<Ayah?> loadLastReadAyah() async {
    final position = await loadLastReadPosition();
    if (position == null) {
      return null;
    }

    return loadAyah(
      surahNumber: position.surahNumber,
      ayahNumber: position.ayahNumber,
    );
  }

  @override
  Future<void> saveLastReadPosition(LastReadPosition position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastReadKey,
      jsonEncode({
        'surahNumber': position.surahNumber,
        'ayahNumber': position.ayahNumber,
        'updatedAt': position.updatedAt.toIso8601String(),
      }),
    );
  }

  Map<String, dynamic> _bookmarkToJson(AyahBookmark bookmark) {
    return {
      'ayahId': bookmark.ayahId,
      'createdAt': bookmark.createdAt.toIso8601String(),
    };
  }
}
