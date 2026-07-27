import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentService {
  Future<bool> updateAndRequestConsentIfNeeded() async {
    await _requestConsentInfoUpdate();

    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
    } catch (_) {
      // A cached consent state can still allow requests when the form fails.
    }

    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPrivacyOptionsRequired() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  Future<bool> showPrivacyOptions() async {
    final completer = Completer<bool>();
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (!completer.isCompleted) {
          completer.complete(error == null);
        }
      });
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    return completer.future;
  }

  Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        (_) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );
    } catch (_) {
      completer.complete();
    }
    return completer.future;
  }
}
