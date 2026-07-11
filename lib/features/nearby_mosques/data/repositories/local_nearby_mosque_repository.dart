import 'dart:math';

import 'package:geolocator/geolocator.dart';

import '../../../prayer_times/domain/entities/selected_prayer_location.dart';
import '../../domain/entities/mosque_distance.dart';
import '../../domain/entities/nearby_mosque_result.dart';
import '../../domain/repositories/nearby_mosque_repository.dart';
import '../datasources/local_json_mosque_data_source.dart';

class LocalNearbyMosqueRepository implements NearbyMosqueRepository {
  const LocalNearbyMosqueRepository({required this.dataSource});

  final LocalJsonMosqueDataSource dataSource;

  @override
  Future<NearbyMosqueResult> loadNearbyMosques(
    SelectedPrayerLocation fallbackLocation, {
    int radiusMeters = 5000,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final mosques = await dataSource.loadMosques();
    final devicePoint = await _tryDeviceLocation();
    final originLatitude =
        devicePoint?.latitude ?? fallbackLocation.district.latitude;
    final originLongitude =
        devicePoint?.longitude ?? fallbackLocation.district.longitude;
    final usesDeviceLocation = devicePoint != null;

    final distances = mosques.map((mosque) {
      return MosqueDistance(
        mosque: mosque,
        distanceMeters: _distanceInMeters(
          originLatitude,
          originLongitude,
          mosque.latitude,
          mosque.longitude,
        ),
        usesDeviceLocation: usesDeviceLocation,
      );
    }).toList();

    distances.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return NearbyMosqueResult(mosques: distances.take(limit).toList());
  }

  Future<({double latitude, double longitude})?> _tryDeviceLocation() async {
    final permission = await Geolocator.checkPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if ((permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) ||
        !serviceEnabled) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } on Object {
      return null;
    }
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
}
