import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../../domain/entities/current_location_resolution.dart';
import '../../domain/entities/selected_prayer_location.dart';
import '../../domain/repositories/current_location_resolver.dart';
import '../datasources/local_json_prayer_location_data_source.dart';
import '../datasources/remote_reverse_geocode_data_source.dart';
import '../models/turkish_location_model.dart';

class GeolocatorCurrentLocationResolver implements CurrentLocationResolver {
  const GeolocatorCurrentLocationResolver({
    required this.locationDataSource,
    required this.reverseGeocodeDataSource,
    this.locationPlatform = const GeolocatorLocationPlatform(),
  });

  static const double _maxCoordinateFallbackDistanceMeters = 100000;

  final LocalJsonPrayerLocationDataSource locationDataSource;
  final RemoteReverseGeocodeDataSource reverseGeocodeDataSource;
  final LocationPlatform locationPlatform;

  @override
  Future<CurrentLocationResolution> resolve() async {
    final serviceEnabled = await locationPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const CurrentLocationResolution(
        status: CurrentLocationResolutionStatus.serviceDisabled,
      );
    }

    var permission = await locationPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationPlatform.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const CurrentLocationResolution(
        status: CurrentLocationResolutionStatus.permissionPermanentlyDenied,
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return const CurrentLocationResolution(
        status: CurrentLocationResolutionStatus.permissionDenied,
      );
    }

    try {
      final position = await _currentOrLastKnownPosition();
      if (position == null) {
        return const CurrentLocationResolution(
          status: CurrentLocationResolutionStatus.unresolved,
        );
      }
      final locations = await locationDataSource.loadLocations();
      if (locations.isEmpty) {
        return const CurrentLocationResolution(
          status: CurrentLocationResolutionStatus.unresolved,
        );
      }

      final administrativeResolution = await _resolveAdministrativeLocation(
        locations,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (administrativeResolution.location != null) {
        return CurrentLocationResolution(
          status: CurrentLocationResolutionStatus.resolved,
          location: administrativeResolution.location,
          usedGoogleAdministrativeLocation: true,
        );
      }
      if (administrativeResolution.wasResolved) {
        return const CurrentLocationResolution(
          status: CurrentLocationResolutionStatus.unresolved,
        );
      }

      final resolvedLocation = _nearestSupportedLocation(
        locations,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (resolvedLocation == null) {
        return const CurrentLocationResolution(
          status: CurrentLocationResolutionStatus.unresolved,
        );
      }

      return CurrentLocationResolution(
        status: CurrentLocationResolutionStatus.resolved,
        location: resolvedLocation,
      );
    } on Object {
      return const CurrentLocationResolution(
        status: CurrentLocationResolutionStatus.unresolved,
      );
    }
  }

  Future<Position?> _currentOrLastKnownPosition() async {
    try {
      return await locationPlatform.getCurrentPosition();
    } on Object {
      return locationPlatform.getLastKnownPosition();
    }
  }

  Future<_AdministrativeResolution> _resolveAdministrativeLocation(
    List<TurkishLocationModel> locations, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      final administrativeLocation = await reverseGeocodeDataSource.resolve(
        latitude: latitude,
        longitude: longitude,
      );
      if (administrativeLocation == null) {
        return const _AdministrativeResolution.unavailable();
      }

      return _AdministrativeResolution.resolved(
        _matchSupportedLocation(
          locations,
          cityName: administrativeLocation.city,
          districtName: administrativeLocation.district,
        ),
      );
    } on Object {
      return const _AdministrativeResolution.unavailable();
    }
  }

  SelectedPrayerLocation? _matchSupportedLocation(
    List<TurkishLocationModel> locations, {
    required String? cityName,
    required String? districtName,
  }) {
    final normalizedCity = _normalize(cityName);
    final normalizedDistrict = _normalize(districtName);
    if (normalizedCity.isEmpty) {
      return null;
    }

    final cityMatches = locations.where(
      (location) => _normalize(location.city.name) == normalizedCity,
    );
    if (cityMatches.isEmpty) {
      return null;
    }

    final location = cityMatches.first;
    if (normalizedDistrict.isEmpty) {
      return null;
    }
    final districtMatches = location.districts.where(
      (district) => _normalize(district.name) == normalizedDistrict,
    );
    if (districtMatches.isEmpty) {
      return null;
    }

    return SelectedPrayerLocation(
      city: location.city,
      district: districtMatches.first,
    );
  }

  SelectedPrayerLocation? _nearestSupportedLocation(
    List<TurkishLocationModel> locations, {
    required double latitude,
    required double longitude,
  }) {
    TurkishLocationModel nearestCity = locations.first;
    var nearestDistrict = locations.first.districts.first;
    var nearestDistance = double.infinity;

    for (final location in locations) {
      for (final district in location.districts) {
        final distance = _distanceInMeters(
          latitude,
          longitude,
          district.latitude,
          district.longitude,
        );
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestCity = location;
          nearestDistrict = district;
        }
      }
    }

    if (nearestDistance > _maxCoordinateFallbackDistanceMeters) {
      return null;
    }

    return SelectedPrayerLocation(
      city: nearestCity.city,
      district: nearestDistrict,
    );
  }

  double _distanceInMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000;
    final startLatRad = _degreesToRadians(startLatitude);
    final endLatRad = _degreesToRadians(endLatitude);
    final deltaLat = _degreesToRadians(endLatitude - startLatitude);
    final deltaLon = _degreesToRadians(endLongitude - startLongitude);

    final a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(startLatRad) *
            cos(endLatRad) *
            sin(deltaLon / 2) *
            sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  String _normalize(String? value) {
    if (value == null) {
      return '';
    }

    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

abstract interface class LocationPlatform {
  Future<bool> isLocationServiceEnabled();

  Future<LocationPermission> checkPermission();

  Future<LocationPermission> requestPermission();

  Future<Position> getCurrentPosition();

  Future<Position?> getLastKnownPosition();
}

class GeolocatorLocationPlatform implements LocationPlatform {
  const GeolocatorLocationPlatform();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position> getCurrentPosition() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 12),
    ),
  );

  @override
  Future<Position?> getLastKnownPosition() => Geolocator.getLastKnownPosition();
}

class _AdministrativeResolution {
  const _AdministrativeResolution.resolved(this.location) : wasResolved = true;

  const _AdministrativeResolution.unavailable()
    : wasResolved = false,
      location = null;

  final bool wasResolved;
  final SelectedPrayerLocation? location;
}
