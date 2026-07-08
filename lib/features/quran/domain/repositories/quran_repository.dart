import '../entities/ayah.dart';
import '../entities/ayah_bookmark.dart';
import '../entities/last_read_position.dart';
import '../entities/surah.dart';

abstract class QuranRepository {
  Future<List<Surah>> loadSurahs();

  Future<Surah> loadSurah(int surahNumber);

  Future<List<Ayah>> loadAyahs(int surahNumber);

  Future<Ayah> loadAyah({required int surahNumber, required int ayahNumber});

  Future<List<AyahBookmark>> loadBookmarks();

  Future<List<Ayah>> loadBookmarkedAyahs();

  Future<void> saveBookmark(AyahBookmark bookmark);

  Future<void> removeBookmark(String ayahId);

  Future<LastReadPosition?> loadLastReadPosition();

  Future<Ayah?> loadLastReadAyah();

  Future<void> saveLastReadPosition(LastReadPosition position);
}
