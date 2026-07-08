import '../entities/current_location_resolution.dart';

abstract class CurrentLocationResolver {
  Future<CurrentLocationResolution> resolve();
}
