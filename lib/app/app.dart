import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/notification_bootstrap_provider.dart';
import '../features/prayer_times/presentation/controllers/prayer_location_controller.dart';
import '../features/prayer_times/presentation/controllers/prayer_notification_controller.dart';
import '../features/daily_content/presentation/controllers/daily_content_controller.dart';
import '../features/settings/presentation/controllers/app_theme_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class IslamicApp extends ConsumerStatefulWidget {
  const IslamicApp({super.key});

  @override
  ConsumerState<IslamicApp> createState() => _IslamicAppState();
}

class _IslamicAppState extends ConsumerState<IslamicApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initialPrayerLocationBootstrapProvider.future);
      ref.read(dailyContentBootstrapProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themePreference = ref.watch(appThemeControllerProvider).asData?.value;
    ref.watch(notificationBootstrapProvider);
    ref.listen(selectedPrayerLocationControllerProvider, (_, _) {
      ref.read(prayerNotificationControllerProvider.notifier).reschedule();
    });

    return MaterialApp.router(
      title: 'İslami Cep',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themePreference?.darkModeEnabled == true
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: router,
    );
  }
}
