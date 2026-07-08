import '../entities/compass_reading.dart';
import '../entities/qibla_direction.dart';

abstract class QiblaRepository {
  Future<QiblaDirection> calculateQiblaDirection();

  Stream<CompassReading> watchCompass();
}
