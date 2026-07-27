import 'dart:io';

import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig._();

  static const _iosProductionAppOpenAdUnitId =
      'ca-app-pub-5683728284748855/7136531200';
  static const _iosTestAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/5575463023';

  static bool get isSupported => !kIsWeb && Platform.isIOS;

  static String get appOpenAdUnitId {
    return kReleaseMode
        ? _iosProductionAppOpenAdUnitId
        : _iosTestAppOpenAdUnitId;
  }
}
