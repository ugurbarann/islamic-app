import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_consent_service.dart';
import 'ad_frequency_store.dart';

class AppOpenAdManager {
  AppOpenAdManager(this._consentService, this._frequencyStore);

  static const _maximumAdAge = Duration(hours: 4);
  static const _startupLoadBudget = Duration(seconds: 2);

  final AdConsentService _consentService;
  final AdFrequencyStore _frequencyStore;

  AppOpenAd? _appOpenAd;
  DateTime? _loadedAt;
  StreamSubscription<AppState>? _appStateSubscription;
  Timer? _startupLoadTimer;
  Future<void> _pendingFrequencyWrite = Future.value();
  VoidCallback? _onStartupComplete;

  int _launchCount = 0;
  bool _started = false;
  bool _stopped = false;
  bool _sdkInitialized = false;
  bool _isLoadingAd = false;
  bool _isShowingAd = false;
  bool _isHandlingForeground = false;
  bool _showOnStartupLoad = false;
  bool _startupCompleted = false;

  Future<void> start({required VoidCallback onStartupComplete}) async {
    if (_started) {
      onStartupComplete();
      return;
    }
    _started = true;
    _stopped = false;
    _onStartupComplete = onStartupComplete;

    if (!AdConfig.isSupported) {
      _completeStartup();
      return;
    }

    try {
      _launchCount = await _frequencyStore.registerLaunch();
    } catch (_) {
      _completeStartup();
      return;
    }

    final initiallyEligible = await _isEligible();
    if (initiallyEligible) {
      _showOnStartupLoad = true;
      _startupLoadTimer = Timer(_startupLoadBudget, () {
        _showOnStartupLoad = false;
        _completeStartup();
      });
    } else {
      _completeStartup();
    }

    final canRequestAds = await _consentService
        .updateAndRequestConsentIfNeeded();
    if (!canRequestAds || _stopped) {
      _completeStartup();
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
      await AppStateEventNotifier.startListening();
      _appStateSubscription = AppStateEventNotifier.appStateStream.listen((
        state,
      ) {
        if (state == AppState.foreground) {
          unawaited(_handleForeground());
        }
      });
    } catch (_) {
      _completeStartup();
      return;
    }

    _loadAd();
  }

  Future<void> stop() async {
    _stopped = true;
    _startupLoadTimer?.cancel();
    _startupLoadTimer = null;
    await _appStateSubscription?.cancel();
    _appStateSubscription = null;
    _disposeLoadedAd();
    if (_sdkInitialized && AdConfig.isSupported) {
      try {
        await AppStateEventNotifier.stopListening();
      } catch (_) {
        // The platform listener may already be stopped during app teardown.
      }
    }
  }

  void _loadAd() {
    if (_stopped || !_sdkInitialized || _isLoadingAd || _hasFreshAd) {
      return;
    }

    _isLoadingAd = true;
    unawaited(
      AppOpenAd.load(
        adUnitId: AdConfig.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoadingAd = false;
            if (_stopped) {
              ad.dispose();
              return;
            }
            _appOpenAd = ad;
            _loadedAt = DateTime.now().toUtc();
            if (_showOnStartupLoad && !_startupCompleted) {
              unawaited(_tryShowAd(isStartup: true));
            }
          },
          onAdFailedToLoad: (_) {
            _handleLoadFailure();
          },
        ),
      ).catchError((_) {
        _handleLoadFailure();
      }),
    );
  }

  void _handleLoadFailure() {
    _isLoadingAd = false;
    if (_showOnStartupLoad && !_startupCompleted) {
      _showOnStartupLoad = false;
      _completeStartup();
    }
  }

  Future<void> _handleForeground() async {
    if (_stopped || !_sdkInitialized || _isShowingAd || _isHandlingForeground) {
      return;
    }

    _isHandlingForeground = true;
    try {
      final eligible = await _isEligible();
      if (!eligible) {
        _loadAd();
        return;
      }
      if (_hasFreshAd) {
        await _tryShowAd(isStartup: false);
      } else {
        _loadAd();
      }
    } finally {
      _isHandlingForeground = false;
    }
  }

  Future<void> _tryShowAd({required bool isStartup}) async {
    if (_stopped || _isShowingAd || !_hasFreshAd) {
      if (isStartup) {
        _completeStartup();
      }
      return;
    }

    final eligible = await _isEligible();
    if (!eligible) {
      if (isStartup) {
        _completeStartup();
      }
      return;
    }

    final ad = _appOpenAd;
    if (ad == null) {
      if (isStartup) {
        _completeStartup();
      }
      return;
    }

    _isShowingAd = true;
    _showOnStartupLoad = false;
    _startupLoadTimer?.cancel();
    _startupLoadTimer = null;
    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (_) {
        _queueFrequencyWrite(_frequencyStore.recordImpression);
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        _clearAdReference(failedAd);
        _isShowingAd = false;
        if (isStartup) {
          _completeStartup();
        }
        _loadAd();
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        _clearAdReference(dismissedAd);
        _isShowingAd = false;
        _queueFrequencyWrite(_frequencyStore.recordDismissal);
        if (isStartup) {
          _completeStartup();
        }
        _loadAd();
      },
    );

    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
      _clearAdReference(ad);
      _isShowingAd = false;
      if (isStartup) {
        _completeStartup();
      }
      _loadAd();
    }
  }

  Future<bool> _isEligible() async {
    try {
      await _pendingFrequencyWrite;
      return await _frequencyStore.canShow(launchCount: _launchCount);
    } catch (_) {
      return false;
    }
  }

  void _queueFrequencyWrite(Future<void> Function() operation) {
    final previousWrite = _pendingFrequencyWrite;
    _pendingFrequencyWrite = () async {
      try {
        await previousWrite;
      } catch (_) {
        // A failed local write must not break the app lifecycle.
      }
      try {
        await operation();
      } catch (_) {
        // Server-side frequency capping remains as a second safeguard.
      }
    }();
  }

  bool get _hasFreshAd {
    final ad = _appOpenAd;
    final loadedAt = _loadedAt;
    if (ad == null || loadedAt == null) {
      return false;
    }
    if (DateTime.now().toUtc().difference(loadedAt) >= _maximumAdAge) {
      _disposeLoadedAd();
      return false;
    }
    return true;
  }

  void _clearAdReference(AppOpenAd ad) {
    if (identical(_appOpenAd, ad)) {
      _appOpenAd = null;
      _loadedAt = null;
    }
  }

  void _disposeLoadedAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _loadedAt = null;
  }

  void _completeStartup() {
    if (_startupCompleted) {
      return;
    }
    _startupCompleted = true;
    _showOnStartupLoad = false;
    _startupLoadTimer?.cancel();
    _startupLoadTimer = null;
    final callback = _onStartupComplete;
    _onStartupComplete = null;
    callback?.call();
  }
}
