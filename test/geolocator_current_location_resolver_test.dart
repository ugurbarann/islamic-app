import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:islamic_app/features/prayer_times/data/datasources/local_json_prayer_location_data_source.dart';
import 'package:islamic_app/features/prayer_times/data/datasources/remote_reverse_geocode_data_source.dart';
import 'package:islamic_app/features/prayer_times/data/models/turkish_location_model.dart';
import 'package:islamic_app/features/prayer_times/data/repositories/geolocator_current_location_resolver.dart';
import 'package:islamic_app/features/prayer_times/domain/entities/current_location_resolution.dart';
import 'package:islamic_app/features/prayer_times/domain/entities/turkish_city.dart';
import 'package:islamic_app/features/prayer_times/domain/entities/turkish_district.dart';

void main() {
  group('GeolocatorCurrentLocationResolver', () {
    test(
      'does not select a Turkish district for New York when reverse geocoding fails',
      () async {
        final resolver = _buildResolver(
          latitude: 40.7128,
          longitude: -74.0060,
          reverseGeocodeShouldFail: true,
        );

        final resolution = await resolver.resolve();

        expect(resolution.status, CurrentLocationResolutionStatus.unresolved);
        expect(resolution.location, isNull);
      },
    );

    test(
      'selects Bodrum for nearby coordinates when reverse geocoding fails',
      () async {
        final resolver = _buildResolver(
          latitude: 37.0344,
          longitude: 27.4305,
          reverseGeocodeShouldFail: true,
        );

        final resolution = await resolver.resolve();

        expect(resolution.status, CurrentLocationResolutionStatus.resolved);
        expect(resolution.location?.city.name, 'Muğla');
        expect(resolution.location?.district.name, 'Bodrum');
        expect(resolution.usedGoogleAdministrativeLocation, isFalse);
      },
    );

    test(
      'keeps the current default when reverse geocoding returns an unsupported location',
      () async {
        final resolver = _buildResolver(
          latitude: 37.0344,
          longitude: 27.4305,
          administrativeLocation: const ResolvedAdministrativeLocation(
            city: 'New York',
            district: 'Manhattan',
          ),
        );

        final resolution = await resolver.resolve();

        expect(resolution.status, CurrentLocationResolutionStatus.unresolved);
        expect(resolution.location, isNull);
      },
    );
  });
}

GeolocatorCurrentLocationResolver _buildResolver({
  required double latitude,
  required double longitude,
  ResolvedAdministrativeLocation? administrativeLocation,
  bool reverseGeocodeShouldFail = false,
}) {
  return GeolocatorCurrentLocationResolver(
    locationDataSource: _FakeLocationDataSource(_supportedLocations),
    reverseGeocodeDataSource: _FakeReverseGeocodeDataSource(
      administrativeLocation,
      shouldFail: reverseGeocodeShouldFail,
    ),
    locationPlatform: _FakeLocationPlatform(
      _position(latitude: latitude, longitude: longitude),
    ),
  );
}

final List<TurkishLocationModel> _supportedLocations = (() {
  const bodrum = TurkishDistrict(
    id: 'bodrum',
    cityId: 'mugla',
    name: 'Bodrum',
    latitude: 37.0344,
    longitude: 27.4305,
  );
  const districts = [bodrum];
  return const [
    TurkishLocationModel(
      city: TurkishCity(id: 'mugla', name: 'Muğla', districts: districts),
      districts: districts,
    ),
  ];
})();

Position _position({required double latitude, required double longitude}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime(2026, 7, 12),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _FakeLocationDataSource extends LocalJsonPrayerLocationDataSource {
  const _FakeLocationDataSource(this.locations);

  final List<TurkishLocationModel> locations;

  @override
  Future<List<TurkishLocationModel>> loadLocations() async => locations;
}

class _FakeReverseGeocodeDataSource extends RemoteReverseGeocodeDataSource {
  _FakeReverseGeocodeDataSource(this.location, {required this.shouldFail});

  final ResolvedAdministrativeLocation? location;
  final bool shouldFail;

  @override
  Future<ResolvedAdministrativeLocation?> resolve({
    required double latitude,
    required double longitude,
  }) async {
    if (shouldFail) {
      throw StateError('Reverse geocoding unavailable');
    }
    return location;
  }
}

class _FakeLocationPlatform implements LocationPlatform {
  const _FakeLocationPlatform(this.position);

  final Position position;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition() async => position;

  @override
  Future<Position?> getLastKnownPosition() async => null;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
