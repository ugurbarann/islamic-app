import '../../../prayer_times/domain/entities/selected_prayer_location.dart';
import '../entities/nearby_mosque_result.dart';

abstract class NearbyMosqueRepository {
  Future<NearbyMosqueResult> loadNearbyMosques(
    SelectedPrayerLocation fallbackLocation, {
    int radiusMeters = 5000,
    int limit = 10,
    bool forceRefresh = false,
  });
}
