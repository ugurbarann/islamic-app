import 'qibla_status.dart';

class QiblaDirection {
  const QiblaDirection({
    required this.status,
    this.qiblaAngle,
    this.heading,
    this.difference,
  });

  final QiblaStatus status;
  final double? qiblaAngle;
  final double? heading;
  final double? difference;

  QiblaDirection withCompassHeading(double? heading) {
    if (status != QiblaStatus.ready || qiblaAngle == null || heading == null) {
      return this;
    }

    return QiblaDirection(
      status: status,
      qiblaAngle: qiblaAngle,
      heading: heading,
      difference: _normalizeDifference(qiblaAngle! - heading),
    );
  }

  double _normalizeDifference(double value) {
    var normalized = (value + 540) % 360 - 180;
    if (normalized == -180) {
      normalized = 180;
    }
    return normalized;
  }
}
