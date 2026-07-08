import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'app_notification_service.dart';

class FlutterLocalNotificationService implements AppNotificationService {
  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    timezone_data.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation('Europe/Istanbul'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await android?.areNotificationsEnabled();
    return enabled ?? true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final alreadyEnabled = await android.areNotificationsEnabled();
      if (alreadyEnabled == true) {
        return true;
      }
      return await android.requestNotificationsPermission() ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      return await macos?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;
    }

    return true;
  }

  @override
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await initialize();
    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: timezone.TZDateTime.from(scheduledAt, timezone.local),
      notificationDetails: prayerNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'prayer:$id',
    );
  }

  @override
  Future<void> scheduleWeeklyFridayReminder({
    required int id,
    required int hour,
    required int minute,
  }) async {
    await initialize();
    final nextFriday = _nextFridayAt(hour: hour, minute: minute);

    await _plugin.zonedSchedule(
      id: id,
      title: 'Cuma Hatırlatıcısı',
      body: 'Cumanız mübarek olsun.',
      scheduledDate: timezone.TZDateTime.from(nextFriday, timezone.local),
      notificationDetails: fridayNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'friday-reminder',
    );
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAllPrayerNotifications() async {
    await initialize();
    for (final id in AppNotificationIds.prayerWindowIds()) {
      await _plugin.cancel(id: id);
    }
  }

  @override
  Future<void> cancelFridayReminder() {
    return cancel(AppNotificationIds.fridayReminder);
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return;
    }

    const prayerChannel = AndroidNotificationChannel(
      prayerNotificationChannelId,
      'Namaz Vakti Bildirimleri',
      description: 'Namaz vakitleri için yerel hatırlatıcılar',
      importance: Importance.high,
    );
    const fridayChannel = AndroidNotificationChannel(
      fridayNotificationChannelId,
      'Cuma Hatırlatıcısı',
      description: 'Her cuma için yerel hatırlatıcı',
      importance: Importance.high,
    );

    await android.createNotificationChannel(prayerChannel);
    await android.createNotificationChannel(fridayChannel);
  }

  DateTime _nextFridayAt({required int hour, required int minute}) {
    final now = DateTime.now();
    var daysUntilFriday = DateTime.friday - now.weekday;
    if (daysUntilFriday < 0) {
      daysUntilFriday += DateTime.daysPerWeek;
    }

    var scheduled = DateTime(
      now.year,
      now.month,
      now.day + daysUntilFriday,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: DateTime.daysPerWeek));
    }
    return scheduled;
  }
}
