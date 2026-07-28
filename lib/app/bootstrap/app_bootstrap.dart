import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/flutter_local_notification_service.dart';
import '../../core/notifications/notification_providers.dart';
import '../app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = FlutterLocalNotificationService();

  runApp(
    ProviderScope(
      overrides: [
        appNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const IslamicApp(),
    ),
  );
}
