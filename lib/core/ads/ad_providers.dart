import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_consent_service.dart';
import 'ad_frequency_store.dart';
import 'app_open_ad_manager.dart';

final adConsentServiceProvider = Provider<AdConsentService>((ref) {
  return AdConsentService();
});

final adFrequencyStoreProvider = Provider<AdFrequencyStore>((ref) {
  return const AdFrequencyStore();
});

final appOpenAdManagerProvider = Provider<AppOpenAdManager>((ref) {
  return AppOpenAdManager(
    ref.watch(adConsentServiceProvider),
    ref.watch(adFrequencyStoreProvider),
  );
});
