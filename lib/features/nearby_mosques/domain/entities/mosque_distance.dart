import 'mosque.dart';

class MosqueDistance {
  const MosqueDistance({
    required this.mosque,
    required this.distanceMeters,
    required this.usesDeviceLocation,
  });

  final Mosque mosque;
  final double distanceMeters;
  final bool usesDeviceLocation;
}
