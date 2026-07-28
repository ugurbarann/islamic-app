import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/notification_bootstrap_provider.dart';
import '../core/ads/ad_providers.dart';
import '../core/ads/app_open_ad_manager.dart';
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
  AppOpenAdManager? _appOpenAdManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _appOpenAdManager = ref.read(appOpenAdManagerProvider);
      unawaited(_startAdsAndPermissionBootstraps(_appOpenAdManager!));
      unawaited(
        _runBootstrap(
          ref.read(dailyContentBootstrapProvider.future),
          'Daily content',
        ),
      );
    });
  }

  @override
  void dispose() {
    final manager = _appOpenAdManager;
    if (manager != null) {
      unawaited(manager.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themePreference = ref.watch(appThemeControllerProvider).asData?.value;
    ref.listen(selectedPrayerLocationControllerProvider, (previous, next) {
      final previousLocation = previous?.asData?.value;
      final nextLocation = next.asData?.value;
      if (previousLocation == null ||
          nextLocation == null ||
          (previousLocation.city.id == nextLocation.city.id &&
              previousLocation.district.id == nextLocation.district.id)) {
        return;
      }
      unawaited(_reschedulePrayerNotifications());
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

  Future<void> _reschedulePrayerNotifications() async {
    try {
      await ref.read(notificationBootstrapProvider.future);
      await ref
          .read(prayerNotificationControllerProvider.notifier)
          .reschedule();
    } catch (error) {
      debugPrint('Prayer notification reschedule failed: $error');
    }
  }

  Future<void> _startAdsAndPermissionBootstraps(
    AppOpenAdManager manager,
  ) async {
    await _runBootstrap(manager.start(), 'App Open ad');
    await manager.startupInteractionComplete;
    if (!mounted) {
      return;
    }

    unawaited(
      _runBootstrap(
        ref.read(notificationBootstrapProvider.future),
        'Notifications',
      ),
    );
    unawaited(
      _runBootstrap(
        ref.read(initialPrayerLocationBootstrapProvider.future),
        'Prayer location',
      ),
    );
  }

  Future<void> _runBootstrap(Future<void> operation, String name) async {
    try {
      await operation;
    } catch (error) {
      debugPrint('$name bootstrap failed: $error');
    }
  }
}
