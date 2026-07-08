import '../entities/tasbih_preferences.dart';

abstract class TasbihPreferencesRepository {
  Future<TasbihPreferences> loadPreferences();

  Future<void> savePreferences(TasbihPreferences preferences);
}
