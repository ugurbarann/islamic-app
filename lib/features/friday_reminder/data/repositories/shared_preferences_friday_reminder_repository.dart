import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/friday_reminder_preference.dart';
import '../../domain/repositories/friday_reminder_repository.dart';

class SharedPreferencesFridayReminderRepository
    implements FridayReminderRepository {
  const SharedPreferencesFridayReminderRepository();

  static const _enabledKey = 'friday_reminder_enabled';

  @override
  Future<FridayReminderPreference> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return FridayReminderPreference(
      enabled: prefs.getBool(_enabledKey) ?? false,
    );
  }

  @override
  Future<void> savePreference(FridayReminderPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, preference.enabled);
  }
}
