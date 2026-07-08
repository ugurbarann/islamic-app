import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prayer_times/presentation/controllers/prayer_location_controller.dart';
import '../../data/datasources/local_json_mosque_data_source.dart';
import '../../data/datasources/remote_backend_mosque_data_source.dart';
import '../../data/repositories/backend_nearby_mosque_repository.dart';
import '../../data/repositories/local_nearby_mosque_repository.dart';
import '../../domain/entities/nearby_mosque_result.dart';
import '../../domain/repositories/nearby_mosque_repository.dart';

final nearbyMosqueRepositoryProvider = Provider<NearbyMosqueRepository>((ref) {
  const localRepository = LocalNearbyMosqueRepository(
    dataSource: LocalJsonMosqueDataSource(),
  );
  return BackendNearbyMosqueRepository(
    remoteDataSource: RemoteBackendMosqueDataSource(),
    localRepository: localRepository,
  );
});

class NearbyMosqueQuery {
  const NearbyMosqueQuery({
    this.radiusMeters = 5000,
    this.limit = 10,
    this.refreshToken = 0,
  });

  final int radiusMeters;
  final int limit;
  final int refreshToken;

  @override
  bool operator ==(Object other) {
    return other is NearbyMosqueQuery &&
        other.radiusMeters == radiusMeters &&
        other.limit == limit &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(radiusMeters, limit, refreshToken);
}

final nearbyMosquesProvider =
    FutureProvider.family<NearbyMosqueResult, NearbyMosqueQuery>((
      ref,
      query,
    ) async {
      final selectedLocation = await ref.watch(
        selectedPrayerLocationControllerProvider.future,
      );
      return ref
          .watch(nearbyMosqueRepositoryProvider)
          .loadNearbyMosques(
            selectedLocation,
            radiusMeters: query.radiusMeters,
            limit: query.limit,
            forceRefresh: query.refreshToken > 0,
          );
    });
