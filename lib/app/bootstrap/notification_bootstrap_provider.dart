import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/app_notification_service.dart';
import '../../core/notifications/notification_providers.dart';
import '../../features/friday_reminder/presentation/controllers/friday_reminder_controller.dart';
import '../../features/prayer_times/presentation/controllers/prayer_notification_controller.dart';
import '../../features/prayer_times/presentation/controllers/prayer_times_controller.dart';

final notificationBootstrapProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.read(appNotificationServiceProvider);
  await notificationService.initialize();

  final fridayPreference = await ref
      .read(fridayReminderRepositoryProvider)
      .loadPreference();
  if (fridayPreference.enabled) {
    final granted = await notificationService.requestPermission();
    if (granted) {
      await notificationService.scheduleWeeklyFridayReminder(
        id: AppNotificationIds.fridayReminder,
        hour: fridayPreference.hour,
        minute: fridayPreference.minute,
      );
    }
  }

  final prayerPreference = await ref
      .read(prayerNotificationPreferenceRepositoryProvider)
      .loadPreference();
  if (!prayerPreference.hasEnabledPrayer) {
    return;
  }

  final granted = await notificationService.requestPermission();
  if (!granted) {
    return;
  }

  final prayerTimeDay = await ref.read(todayPrayerTimesProvider.future);
  await notificationService.cancelAllPrayerNotifications();
  await schedulePrayerNotifications(
    notificationService: notificationService,
    preference: prayerPreference,
    prayerTimeDay: prayerTimeDay,
  );
});
