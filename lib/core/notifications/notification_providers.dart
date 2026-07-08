import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification_service.dart';
import 'flutter_local_notification_service.dart';

final appNotificationServiceProvider = Provider<AppNotificationService>((ref) {
  return FlutterLocalNotificationService();
});
