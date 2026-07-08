import '../entities/selected_prayer_location.dart';
import '../entities/turkish_city.dart';
import '../entities/turkish_district.dart';

abstract class PrayerLocationRepository {
  Future<List<TurkishCity>> loadCities();

  Future<List<TurkishDistrict>> loadDistricts(String cityId);

  Future<SelectedPrayerLocation> loadSelectedLocation();

  Future<void> saveSelectedLocation({
    required String cityId,
    required String districtId,
  });
}
