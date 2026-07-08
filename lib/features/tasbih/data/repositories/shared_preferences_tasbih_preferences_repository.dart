import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/tasbih_preferences.dart';
import '../../domain/repositories/tasbih_preferences_repository.dart';

class SharedPreferencesTasbihPreferencesRepository
    implements TasbihPreferencesRepository {
  const SharedPreferencesTasbihPreferencesRepository();

  static const _hapticFeedbackKey = 'tasbih_haptic_feedback_enabled';

  @override
  Future<TasbihPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return TasbihPreferences(
      hapticFeedbackEnabled: prefs.getBool(_hapticFeedbackKey) ?? true,
    );
  }

  @override
  Future<void> savePreferences(TasbihPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, preferences.hapticFeedbackEnabled);
  }
}
