import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/app_notification_service.dart';
import '../../../../core/notifications/notification_providers.dart';
import '../../data/repositories/shared_preferences_prayer_notification_preference_repository.dart';
import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_notification_preference.dart';
import '../../domain/entities/prayer_time_day.dart';
import '../../domain/repositories/prayer_notification_preference_repository.dart';
import 'prayer_times_controller.dart';

final prayerNotificationPreferenceRepositoryProvider =
    Provider<PrayerNotificationPreferenceRepository>((ref) {
      return const SharedPreferencesPrayerNotificationPreferenceRepository();
    });

final prayerNotificationControllerProvider =
    AsyncNotifierProvider<
      PrayerNotificationController,
      PrayerNotificationPreference
    >(PrayerNotificationController.new);

class PrayerNotificationController
    extends AsyncNotifier<PrayerNotificationPreference> {
  @override
  Future<PrayerNotificationPreference> build() {
    return ref
        .watch(prayerNotificationPreferenceRepositoryProvider)
        .loadPreference();
  }

  Future<bool> setPrayerEnabled({
    required PrayerName prayerName,
    required bool enabled,
  }) async {
    final current =
        state.asData?.value ??
        await ref
            .read(prayerNotificationPreferenceRepositoryProvider)
            .loadPreference();

    final requestedPreference = current.copyWithPrayer(
      prayerName: prayerName,
      enabled: enabled,
    );

    if (requestedPreference.hasEnabledPrayer) {
      final granted = await ref
          .read(appNotificationServiceProvider)
          .requestPermission();
      if (!granted) {
        state = AsyncData(
          current.copyWithPrayer(prayerName: prayerName, enabled: false),
        );
        return false;
      }
    }

    await ref
        .read(prayerNotificationPreferenceRepositoryProvider)
        .savePreference(requestedPreference);
    state = AsyncData(requestedPreference);
    await reschedule();
    return true;
  }

  Future<void> setReminderOffsetMinutes(int minutes) async {
    final current =
        state.asData?.value ??
        await ref
            .read(prayerNotificationPreferenceRepositoryProvider)
            .loadPreference();
    final next = current.copyWithOffset(minutes);
    await ref
        .read(prayerNotificationPreferenceRepositoryProvider)
        .savePreference(next);
    state = AsyncData(next);
    await reschedule();
  }

  Future<void> reschedule() async {
    final preference =
        state.asData?.value ??
        await ref
            .read(prayerNotificationPreferenceRepositoryProvider)
            .loadPreference();
    final notificationService = ref.read(appNotificationServiceProvider);

    await notificationService.cancelAllPrayerNotifications();
    if (!preference.hasEnabledPrayer) {
      return;
    }

    final prayerTimeDay = await ref.read(todayPrayerTimesProvider.future);
    await schedulePrayerNotifications(
      notificationService: notificationService,
      preference: preference,
      prayerTimeDay: prayerTimeDay,
    );
  }
}

Future<void> schedulePrayerNotifications({
  required AppNotificationService notificationService,
  required PrayerNotificationPreference preference,
  required PrayerTimeDay prayerTimeDay,
}) async {
  final now = DateTime.now();

  for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
    for (final prayerName in PrayerNotificationPreference.configurablePrayers) {
      if (!preference.isEnabled(prayerName)) {
        continue;
      }

      final baseTime = prayerTimeDay.timeFor(prayerName);
      final scheduledAt = DateTime(
        prayerTimeDay.date.year,
        prayerTimeDay.date.month,
        prayerTimeDay.date.day + dayOffset,
        baseTime.hour,
        baseTime.minute,
      ).subtract(Duration(minutes: preference.reminderOffsetMinutes));
      if (!scheduledAt.isAfter(now)) {
        continue;
      }

      final body = preference.reminderOffsetMinutes == 0
          ? '${prayerName.label} vakti girdi.'
          : '${prayerName.label} vaktine ${_offsetLabel(preference.reminderOffsetMinutes)} kaldı.';
      await notificationService.schedulePrayerNotification(
        id: AppNotificationIds.prayer(
          dayOffset: dayOffset,
          prayerIndex: prayerName.index,
        ),
        title: preference.reminderOffsetMinutes == 0
            ? '${prayerName.label} vakti'
            : '${prayerName.label} hatırlatıcısı',
        body: body,
        scheduledAt: scheduledAt,
      );
    }
  }
}

String _offsetLabel(int minutes) {
  if (minutes == 60) {
    return '1 saat';
  }
  return '$minutes dakika';
}
