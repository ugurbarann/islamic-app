import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/notifications/flutter_local_notification_service.dart';
import '../../core/notifications/notification_providers.dart';
import '../app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final notificationService = FlutterLocalNotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const IslamicApp(),
    ),
  );
}
