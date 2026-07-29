import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_app_initializer.dart';

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  return AppAnalytics();
});

class AppAnalytics {
  FirebaseAnalytics? _analytics;
  Future<void>? _initialization;

  bool get _isSupported {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> initialize() async {
    if (!_isSupported || _analytics != null) {
      return;
    }

    final existing = _initialization;
    if (existing != null) {
      try {
        await existing;
      } catch (error) {
        debugPrint('[Analytics] Initialization failed: $error');
      }
      return;
    }

    final initialization = _initialize();
    _initialization = initialization;
    try {
      await initialization;
    } catch (error) {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
      debugPrint('[Analytics] Initialization failed: $error');
    }
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await initialize();
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error) {
      debugPrint('[Analytics] Event "$name" failed: $error');
    }
  }

  Future<void> logScreenView(String screenName) async {
    await initialize();
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: 'Flutter',
      );
    } catch (error) {
      debugPrint('[Analytics] Screen "$screenName" failed: $error');
    }
  }

  Future<void> _initialize() async {
    await FirebaseAppInitializer.ensureInitialized();
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
    _analytics = analytics;
    debugPrint('[Analytics] Collection enabled');
  }
}
