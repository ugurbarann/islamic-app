import '../entities/friday_reminder_preference.dart';

abstract class FridayReminderRepository {
  Future<FridayReminderPreference> loadPreference();

  Future<void> savePreference(FridayReminderPreference preference);
}
