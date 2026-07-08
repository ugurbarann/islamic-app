import '../entities/app_theme_preference.dart';

abstract class AppThemePreferenceRepository {
  Future<AppThemePreference> loadPreference();

  Future<void> savePreference(AppThemePreference preference);
}
