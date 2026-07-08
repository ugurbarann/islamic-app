import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/quran_reading_preferences.dart';
import '../../domain/repositories/quran_reading_preferences_repository.dart';

class SharedPreferencesQuranReadingPreferencesRepository
    implements QuranReadingPreferencesRepository {
  const SharedPreferencesQuranReadingPreferencesRepository();

  static const _showTransliterationKey = 'quran_show_transliteration';
  static const _showTranslationKey = 'quran_show_translation';
  static const _arabicTextSizeKey = 'quran_arabic_text_size';
  static const _translationTextSizeKey = 'quran_translation_text_size';

  @override
  Future<QuranReadingPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = QuranReadingPreferences();

    return QuranReadingPreferences(
      showTransliteration:
          prefs.getBool(_showTransliterationKey) ??
          defaults.showTransliteration,
      showTranslation:
          prefs.getBool(_showTranslationKey) ?? defaults.showTranslation,
      arabicTextSize:
          prefs.getDouble(_arabicTextSizeKey) ?? defaults.arabicTextSize,
      translationTextSize:
          prefs.getDouble(_translationTextSizeKey) ??
          defaults.translationTextSize,
    );
  }

  @override
  Future<void> savePreferences(QuranReadingPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _showTransliterationKey,
      preferences.showTransliteration,
    );
    await prefs.setBool(_showTranslationKey, preferences.showTranslation);
    await prefs.setDouble(_arabicTextSizeKey, preferences.arabicTextSize);
    await prefs.setDouble(
      _translationTextSizeKey,
      preferences.translationTextSize,
    );
  }
}
