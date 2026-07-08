import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/selected_prayer_location.dart';
import '../../domain/entities/turkish_city.dart';
import '../../domain/entities/turkish_district.dart';
import '../../domain/repositories/prayer_location_repository.dart';
import '../datasources/ezan_vakti_remote_data_source.dart';
import '../datasources/local_json_prayer_location_data_source.dart';
import '../datasources/prayer_times_cache_data_source.dart';
import '../models/ezan_vakti_district_model.dart';
import '../models/turkish_location_model.dart';

class SharedPreferencesPrayerLocationRepository
    implements PrayerLocationRepository {
  const SharedPreferencesPrayerLocationRepository({
    required this.dataSource,
    required this.remoteDataSource,
    required this.cacheDataSource,
  });

  static const _cityKey = 'selected_prayer_city_id';
  static const _districtKey = 'selected_prayer_district_id';
  static const _defaultCityId = 'istanbul';
  static const _defaultDistrictId = 'kadikoy';

  final LocalJsonPrayerLocationDataSource dataSource;
  final EzanVaktiRemoteDataSource remoteDataSource;
  final PrayerTimesCacheDataSource cacheDataSource;

  @override
  Future<List<TurkishCity>> loadCities() async {
    final locations = await dataSource.loadLocations();
    return locations.map((location) => location.city).toList(growable: false);
  }

  @override
  Future<List<TurkishDistrict>> loadDistricts(String cityId) async {
    final locations = await dataSource.loadLocations();
    final location = locations.firstWhere(
      (item) => item.city.id == cityId,
      orElse: () => locations.first,
    );
    final ezanVaktiCityId = location.city.ezanVaktiCityId;
    if (ezanVaktiCityId == null) {
      return location.districts;
    }

    try {
      final remoteDistricts = await remoteDataSource.loadDistricts(
        ezanVaktiCityId,
      );
      await cacheDataSource.saveDistricts(
        cityId: cityId,
        districts: remoteDistricts,
      );
      return _mapRemoteDistricts(location, remoteDistricts);
    } on Object {
      final cachedDistricts = await cacheDataSource.loadDistricts(cityId);
      if (cachedDistricts != null && cachedDistricts.isNotEmpty) {
        return _mapRemoteDistricts(location, cachedDistricts);
      }
      return location.districts;
    }
  }

  @override
  Future<SelectedPrayerLocation> loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cityId = prefs.getString(_cityKey) ?? _defaultCityId;
    final districtId = prefs.getString(_districtKey) ?? _defaultDistrictId;
    final locations = await dataSource.loadLocations();

    final location = locations.firstWhere(
      (item) => item.city.id == cityId,
      orElse: () => locations.firstWhere(
        (item) => item.city.id == _defaultCityId,
        orElse: () => locations.first,
      ),
    );

    final localDistrict = location.districts.where(
      (item) => item.id == districtId,
    );
    if (localDistrict.isNotEmpty) {
      return SelectedPrayerLocation(
        city: location.city,
        district: localDistrict.first,
      );
    }

    final districts = await loadDistricts(location.city.id);
    final district = districts.firstWhere(
      (item) => item.id == districtId,
      orElse: () => districts.first,
    );

    return SelectedPrayerLocation(city: location.city, district: district);
  }

  @override
  Future<void> saveSelectedLocation({
    required String cityId,
    required String districtId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, cityId);
    await prefs.setString(_districtKey, districtId);
  }

  List<TurkishDistrict> _mapRemoteDistricts(
    TurkishLocationModel location,
    List<EzanVaktiDistrictModel> remoteDistricts,
  ) {
    final localDistricts = location.districts;
    final fallbackDistrict = localDistricts.isNotEmpty
        ? localDistricts.first
        : const TurkishDistrict(
            id: 'merkez',
            cityId: 'istanbul',
            name: 'Merkez',
            latitude: 41.0082,
            longitude: 28.9784,
          );
    final mappedDistricts = remoteDistricts
        .map(
          (district) => district.toEntity(
            cityId: location.city.id,
            fallbackLatitude: fallbackDistrict.latitude,
            fallbackLongitude: fallbackDistrict.longitude,
          ),
        )
        .toList(growable: false);
    mappedDistricts.sort((first, second) {
      final firstIsCenter = _sameName(first.name, location.city.name);
      final secondIsCenter = _sameName(second.name, location.city.name);
      if (firstIsCenter == secondIsCenter) {
        return first.name.compareTo(second.name);
      }
      return firstIsCenter ? -1 : 1;
    });
    return mappedDistricts;
  }

  bool _sameName(String first, String second) {
    return first.toLowerCase() == second.toLowerCase();
  }
}
