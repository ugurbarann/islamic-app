import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/app_theme_preference_repository.dart';

class SharedPreferencesAppThemePreferenceRepository
    implements AppThemePreferenceRepository {
  const SharedPreferencesAppThemePreferenceRepository();

  static const _darkModeKey = 'app_theme_dark_mode_enabled';

  @override
  Future<AppThemePreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return AppThemePreference(
      darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
    );
  }

  @override
  Future<void> savePreference(AppThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, preference.darkModeEnabled);
  }
}
