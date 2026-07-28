import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentService {
  Future<bool> updateAndRequestConsentIfNeeded() async {
    final updateError = await _requestConsentInfoUpdate();
    if (updateError != null) {
      _log(
        'Consent info update failed: code=${updateError.errorCode}, '
        'message=${updateError.message}',
      );
    }

    FormError? formError;
    try {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        formError = error;
      });
      if (formError != null) {
        _log(
          'Consent form failed: code=${formError!.errorCode}, '
          'message=${formError!.message}',
        );
      }
    } catch (error) {
      // A cached consent state can still allow requests when the form fails.
      _log('Consent form call failed: $error');
    }

    try {
      final status = await ConsentInformation.instance.getConsentStatus();
      final canRequestAds = await ConsentInformation.instance.canRequestAds();
      _log('Consent status=$status, canRequestAds=$canRequestAds');
      return canRequestAds;
    } catch (error) {
      _log('Consent state check failed: $error');
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

  Future<FormError?> _requestConsentInfoUpdate() {
    final completer = Completer<FormError?>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        (error) {
          if (!completer.isCompleted) {
            completer.complete(error);
          }
        },
      );
    } catch (error) {
      _log('Consent update call failed: $error');
      completer.complete(FormError(errorCode: 0, message: '$error'));
    }
    return completer.future;
  }

  void _log(String message) {
    debugPrint('[AdConsent] $message');
  }
}
