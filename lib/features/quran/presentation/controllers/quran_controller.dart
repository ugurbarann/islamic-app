import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_json_quran_data_source.dart';
import '../../data/repositories/local_quran_repository.dart';
import '../../data/repositories/shared_preferences_quran_reading_preferences_repository.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/ayah_bookmark.dart';
import '../../domain/entities/last_read_position.dart';
import '../../domain/entities/quran_reading_preferences.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_reading_preferences_repository.dart';
import '../../domain/repositories/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return const LocalQuranRepository(dataSource: LocalJsonQuranDataSource());
});

final surahListProvider = FutureProvider<List<Surah>>((ref) {
  return ref.watch(quranRepositoryProvider).loadSurahs();
});

final surahAyahsProvider = FutureProvider.family<List<Ayah>, int>((
  ref,
  surahNumber,
) {
  return ref.watch(quranRepositoryProvider).loadAyahs(surahNumber);
});

final surahProvider = FutureProvider.family<Surah, int>((ref, surahNumber) {
  return ref.watch(quranRepositoryProvider).loadSurah(surahNumber);
});

final quranSearchProvider = FutureProvider.family<List<Ayah>, String>((
  ref,
  query,
) async {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.length < 2) {
    return const [];
  }

  final repository = ref.watch(quranRepositoryProvider);
  final surahs = await repository.loadSurahs();
  final results = <Ayah>[];

  for (final surah in surahs) {
    final ayahs = await repository.loadAyahs(surah.number);
    for (final ayah in ayahs) {
      final transliteration = ayah.turkishTransliteration?.toLowerCase() ?? '';
      if (ayah.turkishTranslation.toLowerCase().contains(normalizedQuery) ||
          ayah.arabicText.contains(query.trim()) ||
          transliteration.contains(normalizedQuery)) {
        results.add(ayah);
      }
    }
  }

  return results.take(80).toList(growable: false);
});

final quranReadingPreferencesRepositoryProvider =
    Provider<QuranReadingPreferencesRepository>((ref) {
      return const SharedPreferencesQuranReadingPreferencesRepository();
    });

final quranReadingPreferencesControllerProvider =
    AsyncNotifierProvider<
      QuranReadingPreferencesController,
      QuranReadingPreferences
    >(QuranReadingPreferencesController.new);

class QuranReadingPreferencesController
    extends AsyncNotifier<QuranReadingPreferences> {
  @override
  Future<QuranReadingPreferences> build() {
    return ref
        .watch(quranReadingPreferencesRepositoryProvider)
        .loadPreferences();
  }

  Future<void> savePreferences(QuranReadingPreferences preferences) async {
    await ref
        .read(quranReadingPreferencesRepositoryProvider)
        .savePreferences(preferences);
    state = AsyncData(preferences);
  }

  Future<void> setShowTransliteration(bool value) async {
    final current = state.asData?.value ?? await build();
    await savePreferences(current.copyWith(showTransliteration: value));
  }

  Future<void> setShowTranslation(bool value) async {
    final current = state.asData?.value ?? await build();
    await savePreferences(current.copyWith(showTranslation: value));
  }

  Future<void> setArabicTextSize(double value) async {
    final current = state.asData?.value ?? await build();
    await savePreferences(current.copyWith(arabicTextSize: value));
  }

  Future<void> setTranslationTextSize(double value) async {
    final current = state.asData?.value ?? await build();
    await savePreferences(current.copyWith(translationTextSize: value));
  }
}

final bookmarkedAyahIdsProvider = Provider<Set<String>>((ref) {
  final bookmarks = ref.watch(quranBookmarksControllerProvider).asData?.value;
  if (bookmarks == null) {
    return const {};
  }
  return bookmarks.map((ayah) => ayah.id).toSet();
});

final quranBookmarksControllerProvider =
    AsyncNotifierProvider<QuranBookmarksController, List<Ayah>>(
      QuranBookmarksController.new,
    );

class QuranBookmarksController extends AsyncNotifier<List<Ayah>> {
  @override
  Future<List<Ayah>> build() {
    return ref.watch(quranRepositoryProvider).loadBookmarkedAyahs();
  }

  Future<void> toggleBookmark(Ayah ayah) async {
    final repository = ref.read(quranRepositoryProvider);
    final bookmarks = await repository.loadBookmarks();
    final isBookmarked = bookmarks.any(
      (bookmark) => bookmark.ayahId == ayah.id,
    );

    if (isBookmarked) {
      await repository.removeBookmark(ayah.id);
    } else {
      await repository.saveBookmark(
        AyahBookmark(ayahId: ayah.id, createdAt: DateTime.now()),
      );
    }

    state = AsyncData(await repository.loadBookmarkedAyahs());
  }
}

final lastReadControllerProvider =
    AsyncNotifierProvider<LastReadController, Ayah?>(LastReadController.new);

class LastReadController extends AsyncNotifier<Ayah?> {
  @override
  Future<Ayah?> build() {
    return ref.watch(quranRepositoryProvider).loadLastReadAyah();
  }

  Future<void> save(Ayah ayah) async {
    await ref
        .read(quranRepositoryProvider)
        .saveLastReadPosition(
          LastReadPosition(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            updatedAt: DateTime.now(),
          ),
        );
    state = AsyncData(ayah);
  }
}
