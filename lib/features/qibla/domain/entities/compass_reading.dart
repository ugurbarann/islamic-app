import 'qibla_status.dart';

class CompassReading {
  const CompassReading({required this.status, this.heading, this.accuracy});

  final QiblaStatus status;
  final double? heading;
  final double? accuracy;
}
