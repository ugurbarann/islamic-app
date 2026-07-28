import 'dart:io';

import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig._();

  static const _iosProductionAppOpenAdUnitId =
      'ca-app-pub-5683728284748855/7136531200';
  static const _iosTestAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/5575463023';
  static const _androidTestAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  static bool get isSupported {
    if (kIsWeb) {
      return false;
    }
    return Platform.isIOS || (!kReleaseMode && Platform.isAndroid);
  }

  static bool get usesTestAds {
    return Platform.isAndroid || !kReleaseMode;
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return _androidTestAppOpenAdUnitId;
    }
    return kReleaseMode
        ? _iosProductionAppOpenAdUnitId
        : _iosTestAppOpenAdUnitId;
  }
}
