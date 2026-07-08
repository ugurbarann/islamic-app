import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../prayer_times/domain/entities/selected_prayer_location.dart';
import '../../domain/entities/mosque.dart';
import '../../domain/entities/mosque_distance.dart';
import '../../domain/entities/nearby_mosque_result.dart';
import '../../domain/repositories/nearby_mosque_repository.dart';
import '../datasources/remote_backend_mosque_data_source.dart';
import 'local_nearby_mosque_repository.dart';

class BackendNearbyMosqueRepository implements NearbyMosqueRepository {
  const BackendNearbyMosqueRepository({
    required this.remoteDataSource,
    required this.localRepository,
  });

  final RemoteBackendMosqueDataSource remoteDataSource;
  final LocalNearbyMosqueRepository localRepository;

  static const _cachePrefix = 'nearby_mosques_cache_v1';
  static const _lastRefreshPrefix = 'nearby_mosques_last_refresh_v1';
  static const _cacheTtl = Duration(hours: 24);
  static const _manualRefreshCooldown = Duration(minutes: 15);

  @override
  Future<NearbyMosqueResult> loadNearbyMosques(
    SelectedPrayerLocation fallbackLocation, {
    int radiusMeters = 5000,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(fallbackLocation, radiusMeters, limit);
    final lastRefreshKey = _lastRefreshKey(
      fallbackLocation,
      radiusMeters,
      limit,
    );
    final now = DateTime.now();
    final nextRefreshAllowedAt = _nextRefreshAllowedAt(prefs, lastRefreshKey);

    if (forceRefresh &&
        nextRefreshAllowedAt != null &&
        now.isBefore(nextRefreshAllowedAt)) {
      final cachedResult = _loadCachedResult(
        prefs,
        cacheKey,
        nextRefreshAllowedAt: nextRefreshAllowedAt,
      );
      if (cachedResult != null) {
        return NearbyMosqueResult(
          mosques: cachedResult.mosques,
          servedFromCache: true,
          fetchedAt: cachedResult.fetchedAt,
          nextRefreshAllowedAt: nextRefreshAllowedAt,
          refreshLimited: true,
          message:
              'Yenilemek için ${_formatRemaining(nextRefreshAllowedAt.difference(now))} bekleyin.',
        );
      }
    }

    if (!forceRefresh) {
      final cachedResult = _loadCachedResult(
        prefs,
        cacheKey,
        maxAge: _cacheTtl,
        nextRefreshAllowedAt: nextRefreshAllowedAt,
      );
      if (cachedResult != null) {
        return cachedResult;
      }
    }

    final origin = await _resolveOrigin(fallbackLocation);

    try {
      final remoteMosques = await remoteDataSource.loadNearbyMosques(
        latitude: origin.latitude,
        longitude: origin.longitude,
        radiusMeters: radiusMeters,
        limit: limit,
        usesDeviceLocation: origin.usesDeviceLocation,
      );
      if (remoteMosques.isEmpty) {
        return _fallbackResult(fallbackLocation, radiusMeters, limit);
      }
      final mosques = remoteMosques.take(limit).toList();
      await _saveCachedResult(
        prefs,
        cacheKey,
        mosques: mosques,
        fetchedAt: now,
      );
      if (forceRefresh) {
        await prefs.setString(lastRefreshKey, now.toIso8601String());
      }
      return NearbyMosqueResult(
        mosques: mosques,
        fetchedAt: now,
        nextRefreshAllowedAt: forceRefresh
            ? now.add(_manualRefreshCooldown)
            : nextRefreshAllowedAt,
      );
    } on Object {
      final cachedResult = _loadCachedResult(
        prefs,
        cacheKey,
        nextRefreshAllowedAt: nextRefreshAllowedAt,
      );
      if (cachedResult != null) {
        return NearbyMosqueResult(
          mosques: cachedResult.mosques,
          servedFromCache: true,
          fetchedAt: cachedResult.fetchedAt,
          nextRefreshAllowedAt: nextRefreshAllowedAt,
          message:
              'Canlı liste alınamadı. Kaydedilen son sonuçlar gösteriliyor.',
        );
      }
      return _fallbackResult(fallbackLocation, radiusMeters, limit);
    }
  }

  String _cacheKey(
    SelectedPrayerLocation location,
    int radiusMeters,
    int limit,
  ) {
    return '$_cachePrefix.${location.city.id}.${location.district.id}.$radiusMeters.$limit';
  }

  String _lastRefreshKey(
    SelectedPrayerLocation location,
    int radiusMeters,
    int limit,
  ) {
    return '$_lastRefreshPrefix.${location.city.id}.${location.district.id}.$radiusMeters.$limit';
  }

  DateTime? _nextRefreshAllowedAt(
    SharedPreferences prefs,
    String lastRefreshKey,
  ) {
    final lastRefresh = DateTime.tryParse(
      prefs.getString(lastRefreshKey) ?? '',
    );
    if (lastRefresh == null) {
      return null;
    }
    return lastRefresh.add(_manualRefreshCooldown);
  }

  NearbyMosqueResult? _loadCachedResult(
    SharedPreferences prefs,
    String cacheKey, {
    Duration? maxAge,
    DateTime? nextRefreshAllowedAt,
  }) {
    final jsonString = prefs.getString(cacheKey);
    if (jsonString == null) {
      return null;
    }

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(map['fetchedAt'] as String);
      if (maxAge != null && DateTime.now().difference(fetchedAt) > maxAge) {
        return null;
      }

      final mosques = (map['items'] as List<dynamic>)
          .map((item) => _mosqueDistanceFromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      if (mosques.isEmpty) {
        return null;
      }

      return NearbyMosqueResult(
        mosques: mosques,
        servedFromCache: true,
        fetchedAt: fetchedAt,
        nextRefreshAllowedAt: nextRefreshAllowedAt,
      );
    } on Object {
      return null;
    }
  }

  Future<void> _saveCachedResult(
    SharedPreferences prefs,
    String cacheKey, {
    required List<MosqueDistance> mosques,
    required DateTime fetchedAt,
  }) async {
    await prefs.setString(
      cacheKey,
      jsonEncode({
        'fetchedAt': fetchedAt.toIso8601String(),
        'items': mosques.map(_mosqueDistanceToJson).toList(growable: false),
      }),
    );
  }

  Map<String, dynamic> _mosqueDistanceToJson(MosqueDistance item) {
    final mosque = item.mosque;
    return {
      'id': mosque.id,
      'cityId': mosque.cityId,
      'name': mosque.name,
      'address': mosque.address,
      'latitude': mosque.latitude,
      'longitude': mosque.longitude,
      'distanceMeters': item.distanceMeters,
      'usesDeviceLocation': item.usesDeviceLocation,
    };
  }

  MosqueDistance _mosqueDistanceFromJson(Map<String, dynamic> json) {
    return MosqueDistance(
      mosque: Mosque(
        id: json['id'] as String,
        cityId: json['cityId'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      usesDeviceLocation: json['usesDeviceLocation'] as bool? ?? false,
    );
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes + (duration.inSeconds % 60 == 0 ? 0 : 1);
    return '$minutes dk';
  }

  Future<NearbyMosqueResult> _fallbackResult(
    SelectedPrayerLocation fallbackLocation,
    int radiusMeters,
    int limit,
  ) async {
    final localResult = await localRepository.loadNearbyMosques(
      fallbackLocation,
      radiusMeters: radiusMeters,
      limit: limit,
    );
    return NearbyMosqueResult(
      mosques: localResult.mosques.take(limit).toList(),
      usedFallback: true,
      message:
          'Canlı cami araması şu anda kullanılamıyor. Kayıtlı camiler gösteriliyor.',
    );
  }

  Future<_MosqueOrigin> _resolveOrigin(
    SelectedPrayerLocation fallbackLocation,
  ) async {
    try {
      return await _resolveDeviceOrigin(
        fallbackLocation,
      ).timeout(const Duration(seconds: 4));
    } on Object {
      return _MosqueOrigin.fromFallback(fallbackLocation);
    }
  }

  Future<_MosqueOrigin> _resolveDeviceOrigin(
    SelectedPrayerLocation fallbackLocation,
  ) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _MosqueOrigin.fromFallback(fallbackLocation);
    }

    var permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
    }

    if (!permission.isGranted) {
      return _MosqueOrigin.fromFallback(fallbackLocation);
    }

    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return _MosqueOrigin(
          latitude: lastKnownPosition.latitude,
          longitude: lastKnownPosition.longitude,
          usesDeviceLocation: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 4),
        ),
      );
      return _MosqueOrigin(
        latitude: position.latitude,
        longitude: position.longitude,
        usesDeviceLocation: true,
      );
    } on Object {
      return _MosqueOrigin.fromFallback(fallbackLocation);
    }
  }
}

class _MosqueOrigin {
  const _MosqueOrigin({
    required this.latitude,
    required this.longitude,
    required this.usesDeviceLocation,
  });

  factory _MosqueOrigin.fromFallback(SelectedPrayerLocation location) {
    return _MosqueOrigin(
      latitude: location.district.latitude,
      longitude: location.district.longitude,
      usesDeviceLocation: false,
    );
  }

  final double latitude;
  final double longitude;
  final bool usesDeviceLocation;
}
