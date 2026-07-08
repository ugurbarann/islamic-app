import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class AppNotificationService {
  Future<void> initialize();

  Future<bool> areNotificationsEnabled();

  Future<bool> requestPermission();

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  });

  Future<void> scheduleWeeklyFridayReminder({
    required int id,
    required int hour,
    required int minute,
  });

  Future<void> cancel(int id);

  Future<void> cancelAllPrayerNotifications();

  Future<void> cancelFridayReminder();
}

class AppNotificationIds {
  const AppNotificationIds._();

  static const fridayReminder = 9001;
  static const _prayerBase = 1000;
  static const _daysToSchedule = 7;
  static const _slotsPerDay = 10;

  static int prayer({required int dayOffset, required int prayerIndex}) {
    return _prayerBase + (dayOffset * _slotsPerDay) + prayerIndex;
  }

  static Iterable<int> prayerWindowIds() sync* {
    for (var dayOffset = 0; dayOffset < _daysToSchedule; dayOffset++) {
      for (var prayerIndex = 0; prayerIndex < _slotsPerDay; prayerIndex++) {
        yield prayer(dayOffset: dayOffset, prayerIndex: prayerIndex);
      }
    }
  }
}

const prayerNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    prayerNotificationChannelId,
    'Namaz Vakti Bildirimleri',
    channelDescription: 'Namaz vakitleri icin yerel hatirlaticilar',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
  ),
  iOS: DarwinNotificationDetails(),
);

const fridayNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    fridayNotificationChannelId,
    'Cuma Hatirlaticisi',
    channelDescription: 'Her cuma icin yerel hatirlatici',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
  ),
  iOS: DarwinNotificationDetails(),
);

const prayerNotificationChannelId = 'prayer_times';
const fridayNotificationChannelId = 'friday_reminder';
