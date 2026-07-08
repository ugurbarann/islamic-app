import '../entities/quran_reading_preferences.dart';

abstract class QuranReadingPreferencesRepository {
  Future<QuranReadingPreferences> loadPreferences();

  Future<void> savePreferences(QuranReadingPreferences preferences);
}
