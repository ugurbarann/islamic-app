import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local_json_prayer_location_data_source.dart';
import '../../data/datasources/ezan_vakti_remote_data_source.dart';
import '../../data/datasources/prayer_times_cache_data_source.dart';
import '../../data/datasources/remote_reverse_geocode_data_source.dart';
import '../../data/repositories/geolocator_current_location_resolver.dart';
import '../../data/repositories/shared_preferences_prayer_location_repository.dart';
import '../../domain/entities/current_location_resolution.dart';
import '../../domain/entities/selected_prayer_location.dart';
import '../../domain/entities/turkish_city.dart';
import '../../domain/entities/turkish_district.dart';
import '../../domain/repositories/current_location_resolver.dart';
import '../../domain/repositories/prayer_location_repository.dart';

final prayerLocationRepositoryProvider = Provider<PrayerLocationRepository>((
  ref,
) {
  return SharedPreferencesPrayerLocationRepository(
    dataSource: const LocalJsonPrayerLocationDataSource(),
    remoteDataSource: EzanVaktiRemoteDataSource(),
    cacheDataSource: const PrayerTimesCacheDataSource(),
  );
});

final currentLocationResolverProvider = Provider<CurrentLocationResolver>((
  ref,
) {
  return GeolocatorCurrentLocationResolver(
    locationDataSource: LocalJsonPrayerLocationDataSource(),
    reverseGeocodeDataSource: RemoteReverseGeocodeDataSource(),
  );
});

final initialPrayerLocationBootstrapProvider = FutureProvider<void>((ref) {
  return ref
      .read(selectedPrayerLocationControllerProvider.notifier)
      .resolveInitialLocationOnce();
});

final turkishCitiesProvider = FutureProvider<List<TurkishCity>>((ref) {
  return ref.watch(prayerLocationRepositoryProvider).loadCities();
});

final turkishDistrictsProvider =
    FutureProvider.family<List<TurkishDistrict>, String>((ref, cityId) {
      return ref.watch(prayerLocationRepositoryProvider).loadDistricts(cityId);
    });

final selectedPrayerLocationControllerProvider =
    AsyncNotifierProvider<
      SelectedPrayerLocationController,
      SelectedPrayerLocation
    >(SelectedPrayerLocationController.new);

class SelectedPrayerLocationController
    extends AsyncNotifier<SelectedPrayerLocation> {
  static const _initialLocationResolvedKey = 'initial_location_resolved_once';
  static const _initialLocationDeniedKey = 'initial_location_permission_denied';

  @override
  Future<SelectedPrayerLocation> build() {
    return ref.watch(prayerLocationRepositoryProvider).loadSelectedLocation();
  }

  Future<void> selectLocation({
    required String cityId,
    required String districtId,
  }) async {
    final repository = ref.read(prayerLocationRepositoryProvider);
    await repository.saveSelectedLocation(
      cityId: cityId,
      districtId: districtId,
    );
    state = AsyncData(await repository.loadSelectedLocation());
  }

  Future<void> selectCity(TurkishCity city) async {
    final districts = await ref.read(turkishDistrictsProvider(city.id).future);

    await selectLocation(cityId: city.id, districtId: districts.first.id);
  }

  Future<void> selectDistrict(TurkishDistrict district) async {
    await selectLocation(cityId: district.cityId, districtId: district.id);
  }

  Future<CurrentLocationResolution> useCurrentLocation() async {
    final resolution = await ref
        .read(currentLocationResolverProvider)
        .resolve();
    final resolvedLocation = resolution.location;

    if (resolution.isResolved && resolvedLocation != null) {
      await selectLocation(
        cityId: resolvedLocation.city.id,
        districtId: resolvedLocation.district.id,
      );
    }

    return resolution;
  }

  Future<void> resolveInitialLocationOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyResolved = prefs.getBool(_initialLocationResolvedKey) ?? false;
    final permissionDenied = prefs.getBool(_initialLocationDeniedKey) ?? false;
    if (alreadyResolved || permissionDenied) {
      return;
    }

    final resolution = await ref
        .read(currentLocationResolverProvider)
        .resolve();
    final resolvedLocation = resolution.location;
    if (resolution.isResolved &&
        resolution.usedGoogleAdministrativeLocation &&
        resolvedLocation != null) {
      await selectLocation(
        cityId: resolvedLocation.city.id,
        districtId: resolvedLocation.district.id,
      );
      await prefs.setBool(_initialLocationResolvedKey, true);
      return;
    }

    if (resolution.status == CurrentLocationResolutionStatus.permissionDenied) {
      await prefs.setBool(_initialLocationDeniedKey, true);
    }
  }
}
