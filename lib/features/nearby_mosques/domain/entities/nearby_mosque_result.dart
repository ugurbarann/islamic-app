import 'mosque_distance.dart';

enum NearbyMosqueLocationStatus {
  available,
  permissionDenied,
  serviceDisabled,
  unavailable,
}

class NearbyMosqueResult {
  const NearbyMosqueResult({
    required this.mosques,
    this.usedFallback = false,
    this.message,
    this.servedFromCache = false,
    this.fetchedAt,
    this.nextRefreshAllowedAt,
    this.refreshLimited = false,
    this.locationStatus = NearbyMosqueLocationStatus.unavailable,
  });

  final List<MosqueDistance> mosques;
  final bool usedFallback;
  final String? message;
  final bool servedFromCache;
  final DateTime? fetchedAt;
  final DateTime? nextRefreshAllowedAt;
  final bool refreshLimited;
  final NearbyMosqueLocationStatus locationStatus;

  NearbyMosqueResult withLocationStatus(
    NearbyMosqueLocationStatus newLocationStatus,
  ) {
    return NearbyMosqueResult(
      mosques: mosques,
      usedFallback: usedFallback,
      message: message,
      servedFromCache: servedFromCache,
      fetchedAt: fetchedAt,
      nextRefreshAllowedAt: nextRefreshAllowedAt,
      refreshLimited: refreshLimited,
      locationStatus: newLocationStatus,
    );
  }
}
