import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/app_analytics.dart';
import 'ad_config.dart';
import 'ad_consent_service.dart';
import 'ad_frequency_store.dart';

class AppOpenAdManager {
  AppOpenAdManager(this._consentService, this._frequencyStore, this._analytics);

  static const _maximumAdAge = Duration(hours: 4);
  static const _startupDelay = Duration(seconds: 10);
  static const _startupGracePeriod = Duration(seconds: 20);
  static const _initializationRetryDelay = Duration(seconds: 30);
  static const _loadRetryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];

  final AdConsentService _consentService;
  final AdFrequencyStore _frequencyStore;
  final AppAnalytics _analytics;

  AppOpenAd? _appOpenAd;
  DateTime? _loadedAt;
  StreamSubscription<AppState>? _appStateSubscription;
  Timer? _startupShowTimer;
  Timer? _startupExpiryTimer;
  Timer? _initializationRetryTimer;
  Timer? _loadRetryTimer;
  Future<void> _pendingFrequencyWrite = Future.value();
  final Completer<void> _startupInteractionCompleter = Completer<void>();

  int _launchCount = 0;
  int _loadRetryAttempt = 0;
  bool _started = false;
  bool _stopped = false;
  bool _isInitializing = false;
  bool _sdkInitialized = false;
  bool _adRequestsAllowed = false;
  bool _lifecycleListening = false;
  bool _isAppForeground = true;
  bool _isLoadingAd = false;
  bool _isShowingAd = false;
  bool _isHandlingForeground = false;
  bool _hasBackgroundedSinceStart = false;
  bool _startupDelayElapsed = false;
  bool _startupShowPending = false;
  bool _startupAttemptCompleted = false;

  Future<void> get startupInteractionComplete =>
      _startupInteractionCompleter.future;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _stopped = false;

    if (!AdConfig.isSupported) {
      _log('Ads are disabled for this platform/build mode');
      _finishStartupInteraction();
      return;
    }

    _log('Starting (${AdConfig.usesTestAds ? 'test' : 'production'} ad unit)');
    _scheduleStartupAttempt();

    try {
      _launchCount = await _frequencyStore.registerLaunch();
      _log('Launch registered: $_launchCount');
    } catch (error) {
      // Local frequency storage should never permanently disable monetization.
      _launchCount = 1;
      _log('Launch registration failed; continuing safely: $error');
    }
    if (_stopped) {
      _finishStartupInteraction();
      return;
    }

    await _startLifecycleListener();
    if (_stopped) {
      _finishStartupInteraction();
      return;
    }
    await _initializeAds();
  }

  Future<void> _startLifecycleListener() async {
    try {
      await AppStateEventNotifier.startListening();
      if (_stopped) {
        try {
          await AppStateEventNotifier.stopListening();
        } catch (_) {
          // The native listener may already have stopped during teardown.
        }
        return;
      }
      _lifecycleListening = true;
      _appStateSubscription = AppStateEventNotifier.appStateStream.listen((
        state,
      ) {
        if (state == AppState.background) {
          _isAppForeground = false;
          _hasBackgroundedSinceStart = true;
          _log('App backgrounded');
          return;
        }

        _isAppForeground = true;
        _log('App foregrounded; checking eligibility');
        if (_adRequestsAllowed) {
          unawaited(_handleForeground());
        } else {
          unawaited(_initializeAds());
        }
      });
    } catch (error) {
      // A cold-start attempt can still work even if lifecycle listening fails.
      _log('Lifecycle listener failed: $error');
    }
  }

  Future<void> _initializeAds() async {
    if (_stopped || _sdkInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    try {
      final canRequestAds = await _consentService
          .updateAndRequestConsentIfNeeded();
      if (!canRequestAds || _stopped) {
        _log('Consent state does not allow ad requests yet');
        _event('app_open_ad_consent_blocked');
        _scheduleInitializationRetry();
        return;
      }

      _adRequestsAllowed = true;
      final initialization = MobileAds.instance.initialize();
      // Google Mobile Ads can initialize from the first request. Starting the
      // load here avoids losing the startup window while adapters initialize.
      _loadAd();
      final status = await initialization;
      if (_stopped) {
        return;
      }
      _sdkInitialized = true;
      _initializationRetryTimer?.cancel();
      _initializationRetryTimer = null;
      _log('Mobile Ads SDK initialized: ${status.adapterStatuses.keys}');
    } catch (error) {
      _log('Mobile Ads initialization failed: $error');
      _scheduleInitializationRetry();
      return;
    } finally {
      _isInitializing = false;
    }

    _loadAd();
  }

  Future<void> stop() async {
    _stopped = true;
    _startupShowTimer?.cancel();
    _startupShowTimer = null;
    _startupExpiryTimer?.cancel();
    _startupExpiryTimer = null;
    _initializationRetryTimer?.cancel();
    _initializationRetryTimer = null;
    _loadRetryTimer?.cancel();
    _loadRetryTimer = null;
    _finishStartupInteraction();
    await _appStateSubscription?.cancel();
    _appStateSubscription = null;
    _disposeLoadedAd();
    if (_lifecycleListening && AdConfig.isSupported) {
      try {
        await AppStateEventNotifier.stopListening();
        _lifecycleListening = false;
      } catch (_) {
        // The platform listener may already be stopped during app teardown.
      }
    }
  }

  void _scheduleStartupAttempt() {
    _startupShowTimer = Timer(_startupDelay, () {
      if (_stopped || _startupAttemptCompleted) {
        return;
      }
      _startupDelayElapsed = true;
      _startupShowPending = true;
      _log('10-second startup point reached');
      unawaited(_tryShowStartupAd());
    });

    _startupExpiryTimer = Timer(_startupDelay + _startupGracePeriod, () {
      if (_stopped || _startupAttemptCompleted) {
        return;
      }
      _completeStartupAttempt();
      _finishStartupInteraction();
      _log('Startup show window expired; keeping the ad for a later resume');
      _event('app_open_ad_startup_expired');
    });
  }

  void _scheduleInitializationRetry() {
    if (_stopped ||
        _sdkInitialized ||
        _initializationRetryTimer?.isActive == true) {
      return;
    }
    _initializationRetryTimer = Timer(_initializationRetryDelay, () {
      _initializationRetryTimer = null;
      unawaited(_initializeAds());
    });
  }

  void _loadAd() {
    if (_stopped || !_adRequestsAllowed || _isLoadingAd || _hasFreshAd) {
      return;
    }

    _loadRetryTimer?.cancel();
    _loadRetryTimer = null;
    _isLoadingAd = true;
    _log('Loading ad: ${AdConfig.appOpenAdUnitId}');
    _event('app_open_ad_request');
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
            _loadRetryAttempt = 0;
            _log('Ad loaded');
            _event('app_open_ad_loaded');
            if (_startupShowPending && _isAppForeground) {
              unawaited(_tryShowStartupAd());
            }
          },
          onAdFailedToLoad: (error) {
            _isLoadingAd = false;
            _log(
              'Ad failed to load: code=${error.code}, '
              'domain=${error.domain}, message=${error.message}, '
              'responseInfo=${error.responseInfo}',
            );
            _event(
              'app_open_ad_load_failed',
              parameters: {
                'error_code': error.code,
                'error_domain': error.domain,
              },
            );
            _scheduleLoadRetry();
          },
        ),
      ).catchError((Object error) {
        _isLoadingAd = false;
        _log('Ad load call failed: $error');
        _scheduleLoadRetry();
      }),
    );
  }

  void _scheduleLoadRetry() {
    if (_stopped || !_adRequestsAllowed || _loadRetryTimer?.isActive == true) {
      return;
    }

    final retryIndex = _loadRetryAttempt < _loadRetryDelays.length
        ? _loadRetryAttempt
        : _loadRetryDelays.length - 1;
    final delay = _loadRetryDelays[retryIndex];
    _loadRetryAttempt++;
    _log('Retrying ad load in ${delay.inSeconds} seconds');
    _loadRetryTimer = Timer(delay, () {
      _loadRetryTimer = null;
      _loadAd();
    });
  }

  Future<void> _tryShowStartupAd() async {
    if (_stopped ||
        _startupAttemptCompleted ||
        !_startupShowPending ||
        !_isAppForeground ||
        _isShowingAd) {
      return;
    }

    if (!_hasFreshAd) {
      _log('Startup ad is waiting for a loaded creative');
      _loadAd();
      return;
    }

    final eligible = await _isEligible(trigger: 'startup');
    if (!eligible) {
      _completeStartupAttempt();
      _finishStartupInteraction();
      return;
    }
    if (!_isAppForeground) {
      return;
    }

    await _showLoadedAd(trigger: 'startup');
  }

  Future<void> _handleForeground() async {
    if (_stopped ||
        !_adRequestsAllowed ||
        _isShowingAd ||
        _isHandlingForeground) {
      return;
    }

    _isHandlingForeground = true;
    try {
      if (_startupShowPending) {
        await _tryShowStartupAd();
        return;
      }
      if (!_startupAttemptCompleted && !_startupDelayElapsed) {
        _log('Foreground arrived before the 10-second startup point');
        _loadAd();
        return;
      }
      if (!_hasBackgroundedSinceStart) {
        return;
      }

      final eligible = await _isEligible(trigger: 'foreground');
      if (!eligible) {
        _loadAd();
        return;
      }
      if (!_isAppForeground) {
        return;
      }
      if (_hasFreshAd) {
        await _showLoadedAd(trigger: 'foreground');
      } else {
        _log('No cached ad on foreground; preloading for the next resume');
        _loadAd();
      }
    } finally {
      _isHandlingForeground = false;
    }
  }

  Future<void> _showLoadedAd({required String trigger}) async {
    if (_stopped ||
        _isShowingAd ||
        !_isAppForeground ||
        !_hasFreshAd ||
        (trigger == 'startup' && _startupAttemptCompleted)) {
      return;
    }

    final ad = _appOpenAd;
    if (ad == null) {
      return;
    }

    _isShowingAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (_) {
        if (trigger == 'startup') {
          _completeStartupAttempt();
        }
        _log('Ad showed ($trigger)');
        _event('app_open_ad_show', parameters: {'trigger': trigger});
        _queueFrequencyWrite(_frequencyStore.recordImpression);
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _log('Ad failed to show: $error');
        _event(
          'app_open_ad_show_failed',
          parameters: {'trigger': trigger, 'error_code': error.code},
        );
        failedAd.dispose();
        _clearAdReference(failedAd);
        _isShowingAd = false;
        if (trigger == 'startup' && _startupAttemptCompleted) {
          _finishStartupInteraction();
        }
        _loadAd();
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _log('Ad dismissed');
        _event('app_open_ad_dismissed', parameters: {'trigger': trigger});
        dismissedAd.dispose();
        _clearAdReference(dismissedAd);
        _isShowingAd = false;
        _queueFrequencyWrite(_frequencyStore.recordDismissal);
        if (trigger == 'startup') {
          _completeStartupAttempt();
          _finishStartupInteraction();
        }
        _loadAd();
      },
    );

    try {
      await ad.show();
    } catch (error) {
      _log('Ad show call failed: $error');
      ad.dispose();
      _clearAdReference(ad);
      _isShowingAd = false;
      _loadAd();
    }
  }

  void _completeStartupAttempt() {
    _startupShowPending = false;
    _startupAttemptCompleted = true;
    _startupShowTimer?.cancel();
    _startupShowTimer = null;
    _startupExpiryTimer?.cancel();
    _startupExpiryTimer = null;
  }

  void _finishStartupInteraction() {
    if (!_startupInteractionCompleter.isCompleted) {
      _startupInteractionCompleter.complete();
    }
  }

  Future<bool> _isEligible({required String trigger}) async {
    try {
      await _pendingFrequencyWrite;
      final eligible = await _frequencyStore.canShow(launchCount: _launchCount);
      _log('Eligibility ($trigger): $eligible');
      return eligible;
    } catch (error) {
      _log('Eligibility check failed: $error');
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

  void _log(String message) {
    debugPrint('[AppOpenAd] $message');
  }

  void _event(String name, {Map<String, Object>? parameters}) {
    unawaited(_analytics.logEvent(name, parameters: parameters));
  }
}
