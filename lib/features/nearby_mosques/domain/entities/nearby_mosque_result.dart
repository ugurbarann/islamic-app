import 'mosque_distance.dart';

class NearbyMosqueResult {
  const NearbyMosqueResult({
    required this.mosques,
    this.usedFallback = false,
    this.message,
    this.servedFromCache = false,
    this.fetchedAt,
    this.nextRefreshAllowedAt,
    this.refreshLimited = false,
  });

  final List<MosqueDistance> mosques;
  final bool usedFallback;
  final String? message;
  final bool servedFromCache;
  final DateTime? fetchedAt;
  final DateTime? nextRefreshAllowedAt;
  final bool refreshLimited;
}
