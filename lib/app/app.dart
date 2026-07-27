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
import 'theme/app_design_system.dart';
import 'theme/app_theme.dart';

class IslamicApp extends ConsumerStatefulWidget {
  const IslamicApp({super.key});

  @override
  ConsumerState<IslamicApp> createState() => _IslamicAppState();
}

class _IslamicAppState extends ConsumerState<IslamicApp> {
  AppOpenAdManager? _appOpenAdManager;
  bool _showStartupAdGate = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initialPrayerLocationBootstrapProvider.future);
      ref.read(dailyContentBootstrapProvider.future);
      _appOpenAdManager = ref.read(appOpenAdManagerProvider);
      unawaited(
        _appOpenAdManager!.start(
          onStartupComplete: () {
            if (mounted) {
              setState(() => _showStartupAdGate = false);
            }
          },
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
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            if (_showStartupAdGate) const _StartupAdGate(),
          ],
        );
      },
    );
  }
}

class _StartupAdGate extends StatelessWidget {
  const _StartupAdGate();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Uygulama hazırlanıyor',
      child: Material(
        color: AppColors.sky,
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.page),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/app/logo.png', width: 82, height: 82),
                  const SizedBox(height: 20),
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
