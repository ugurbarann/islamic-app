import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/app_notification_service.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../data/repositories/shared_preferences_friday_reminder_repository.dart';
import '../../domain/entities/friday_reminder_preference.dart';
import '../../domain/repositories/friday_reminder_repository.dart';

final fridayReminderRepositoryProvider = Provider<FridayReminderRepository>((
  ref,
) {
  return const SharedPreferencesFridayReminderRepository();
});

final fridayReminderControllerProvider =
    AsyncNotifierProvider<FridayReminderController, FridayReminderPreference>(
      FridayReminderController.new,
    );

class FridayReminderController extends AsyncNotifier<FridayReminderPreference> {
  @override
  Future<FridayReminderPreference> build() {
    return ref.watch(fridayReminderRepositoryProvider).loadPreference();
  }

  Future<bool> setEnabled(bool enabled) async {
    const hour = 10;
    const minute = 0;
    final notificationService = ref.read(appNotificationServiceProvider);

    if (enabled) {
      final granted = await notificationService.requestPermission();
      if (!granted) {
        return false;
      }
    }

    final preference = FridayReminderPreference(
      enabled: enabled,
      hour: hour,
      minute: minute,
    );
    await ref.read(fridayReminderRepositoryProvider).savePreference(preference);
    state = AsyncData(preference);

    if (enabled) {
      await notificationService.scheduleWeeklyFridayReminder(
        id: AppNotificationIds.fridayReminder,
        hour: hour,
        minute: minute,
      );
    } else {
      await notificationService.cancelFridayReminder();
    }
    return true;
  }
}

final isFridayProvider = Provider<bool>((ref) {
  return DateTime.now().weekday == DateTime.friday;
});
