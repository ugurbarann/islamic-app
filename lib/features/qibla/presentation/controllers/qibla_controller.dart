import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_qibla_repository.dart';
import '../../domain/entities/compass_reading.dart';
import '../../domain/entities/qibla_direction.dart';
import '../../domain/entities/qibla_status.dart';
import '../../domain/repositories/qibla_repository.dart';

final qiblaRepositoryProvider = Provider<QiblaRepository>((ref) {
  return const DeviceQiblaRepository();
});

final qiblaDirectionProvider = FutureProvider<QiblaDirection>((ref) {
  return ref.watch(qiblaRepositoryProvider).calculateQiblaDirection();
});

final compassReadingProvider = StreamProvider<CompassReading>((ref) {
  return ref.watch(qiblaRepositoryProvider).watchCompass();
});

String qiblaStatusMessage(QiblaStatus status) {
  return switch (status) {
    QiblaStatus.calculating => 'Kıble yönü hesaplanıyor',
    QiblaStatus.ready => 'Kıble Yönü',
    QiblaStatus.locationPermissionRequired => 'Konum izni gerekli',
    QiblaStatus.locationServiceDisabled => 'Konum servisleri kapalı',
    QiblaStatus.compassUnavailable => 'Pusula sensörü kullanılamıyor',
    QiblaStatus.unavailable => 'Kıble yönü hesaplanıyor',
  };
}
