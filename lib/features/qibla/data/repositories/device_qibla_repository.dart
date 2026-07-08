import 'dart:async';
import 'dart:math';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/compass_reading.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/entities/qibla_status.dart';
import '../../domain/repositories/qibla_repository.dart';

class DeviceQiblaRepository implements QiblaRepository {
  const DeviceQiblaRepository();

  static const _kaabaLatitude = 21.4225;
  static const _kaabaLongitude = 39.8262;

  @override
  Future<QiblaDirection> calculateQiblaDirection() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const QiblaDirection(status: QiblaStatus.locationServiceDisabled);
    }

    final permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) {
      return const QiblaDirection(
        status: QiblaStatus.locationPermissionRequired,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return QiblaDirection(
        status: QiblaStatus.ready,
        qiblaAngle: _bearingToKaaba(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on Object {
      return const QiblaDirection(status: QiblaStatus.unavailable);
    }
  }

  @override
  Stream<CompassReading> watchCompass() {
    final events = FlutterCompass.events;
    if (events == null) {
      return Stream.value(
        const CompassReading(status: QiblaStatus.compassUnavailable),
      );
    }

    return events.transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          final heading = event.heading;
          if (heading == null) {
            sink.add(
              const CompassReading(status: QiblaStatus.compassUnavailable),
            );
            return;
          }

          sink.add(
            CompassReading(
              status: QiblaStatus.ready,
              heading: _normalizeAngle(heading),
              accuracy: event.accuracy,
            ),
          );
        },
        handleError: (error, stackTrace, sink) {
          sink.add(
            const CompassReading(status: QiblaStatus.compassUnavailable),
          );
        },
      ),
    );
  }

  double _bearingToKaaba({
    required double latitude,
    required double longitude,
  }) {
    final userLat = _degreesToRadians(latitude);
    final userLon = _degreesToRadians(longitude);
    final kaabaLat = _degreesToRadians(_kaabaLatitude);
    final kaabaLon = _degreesToRadians(_kaabaLongitude);
    final deltaLon = kaabaLon - userLon;

    final y = sin(deltaLon);
    final x = cos(userLat) * tan(kaabaLat) - sin(userLat) * cos(deltaLon);
    return _normalizeAngle(_radiansToDegrees(atan2(y, x)));
  }

  double _normalizeAngle(double value) => (value + 360) % 360;

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  double _radiansToDegrees(double radians) => radians * 180 / pi;
}
