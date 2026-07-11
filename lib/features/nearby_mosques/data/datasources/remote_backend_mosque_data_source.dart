import 'dart:math';

import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/mosque.dart';
import '../../domain/entities/mosque_distance.dart';

class RemoteBackendMosqueDataSource {
  RemoteBackendMosqueDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio _dio;

  Future<List<MosqueDistance>> loadNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 10,
    required bool usesDeviceLocation,
  }) async {
    Object? lastError;
    for (final baseUrl in AppConfig.mosqueBackendBaseUrls) {
      try {
        final response = await _dio.getUri<Map<String, dynamic>>(
          Uri.parse(baseUrl).replace(
            path: '/api/nearby-mosques',
            queryParameters: {
              'lat': latitude.toString(),
              'lng': longitude.toString(),
              'radius': radiusMeters.toString(),
              'limit': limit.toString(),
            },
          ),
        );

        final parsed = _parseMosques(
          response.data?['items'],
          limit: limit,
          usesDeviceLocation: usesDeviceLocation,
        );
        if (parsed.isNotEmpty) {
          return parsed;
        }
      } on Object catch (error) {
        lastError = error;
      }
    }

    for (final endpoint in AppConfig.overpassBaseUrls) {
      try {
        final mosques = await _loadFromOverpass(
          endpoint: endpoint,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          limit: limit,
          usesDeviceLocation: usesDeviceLocation,
        );
        if (mosques.isNotEmpty) {
          return mosques;
        }
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    return const [];
  }

  Future<List<MosqueDistance>> _loadFromOverpass({
    required String endpoint,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required int limit,
    required bool usesDeviceLocation,
  }) async {
    final query =
        '''
[out:json][timeout:12];
(
  nwr["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  nwr["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';
    final response = await _dio.postUri<Map<String, dynamic>>(
      Uri.parse(endpoint),
      data: {'data': query},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: const {'User-Agent': 'IslamiCep/1.0.5'},
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    final elements = response.data?['elements'];
    if (elements is! List) {
      return const [];
    }

    final results = <MosqueDistance>[];
    final seen = <String>{};
    for (final raw in elements.whereType<Map<String, dynamic>>()) {
      final center = raw['center'];
      final centerMap = center is Map ? center.cast<String, dynamic>() : null;
      final mosqueLatitude = _toDouble(raw['lat'] ?? centerMap?['lat']);
      final mosqueLongitude = _toDouble(raw['lon'] ?? centerMap?['lon']);
      if (mosqueLatitude == null || mosqueLongitude == null) {
        continue;
      }

      final tagsValue = raw['tags'];
      final tags = tagsValue is Map
          ? tagsValue.cast<String, dynamic>()
          : const <String, dynamic>{};
      final name = _cleanText(
        tags['name:tr'] ?? tags['name'] ?? tags['name:en'],
      );
      final address = _overpassAddress(tags, mosqueLatitude, mosqueLongitude);
      final displayName = _displayName(name, address);
      if (displayName == null) {
        continue;
      }
      final uniqueKey =
          '${mosqueLatitude.toStringAsFixed(5)}:'
          '${mosqueLongitude.toStringAsFixed(5)}:$displayName';
      if (!seen.add(uniqueKey)) {
        continue;
      }

      final type = _cleanText(raw['type']) ?? 'place';
      final id = _cleanText(raw['id']) ?? uniqueKey;
      results.add(
        MosqueDistance(
          mosque: Mosque(
            id: 'osm:$type:$id',
            cityId: 'remote',
            name: displayName,
            address: address,
            latitude: mosqueLatitude,
            longitude: mosqueLongitude,
          ),
          distanceMeters: _distanceInMeters(
            latitude,
            longitude,
            mosqueLatitude,
            mosqueLongitude,
          ),
          usesDeviceLocation: usesDeviceLocation,
        ),
      );
    }

    results.sort(
      (first, second) => first.distanceMeters.compareTo(second.distanceMeters),
    );
    return results.take(limit).toList(growable: false);
  }

  String _overpassAddress(
    Map<String, dynamic> tags,
    double latitude,
    double longitude,
  ) {
    final street = _cleanText(tags['addr:street']);
    final houseNumber = _cleanText(tags['addr:housenumber']);
    final locality = _cleanText(
      tags['addr:suburb'] ?? tags['addr:district'] ?? tags['addr:place'],
    );
    final city = _cleanText(tags['addr:city'] ?? tags['addr:province']);
    final parts = <String>[
      if (street != null)
        '$street${houseNumber == null ? '' : ' $houseNumber'}',
      ?locality,
      ?city,
    ];
    if (parts.isNotEmpty) {
      return parts.toSet().join(', ');
    }
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  double _distanceInMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000;
    final startLat = startLatitude * pi / 180;
    final endLat = endLatitude * pi / 180;
    final deltaLat = (endLatitude - startLatitude) * pi / 180;
    final deltaLon = (endLongitude - startLongitude) * pi / 180;
    final value =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(startLat) * cos(endLat) * sin(deltaLon / 2) * sin(deltaLon / 2);
    return earthRadiusMeters * 2 * atan2(sqrt(value), sqrt(1 - value));
  }

  List<MosqueDistance> _parseMosques(
    Object? items, {
    required int limit,
    required bool usesDeviceLocation,
  }) {
    if (items is! List) {
      return const [];
    }

    final mosques = <MosqueDistance>[];
    for (final item in items.whereType<Map<String, dynamic>>().take(limit)) {
      final latitude = _toDouble(item['latitude']);
      final longitude = _toDouble(item['longitude']);
      final distanceMeters = _toDouble(item['distanceMeters']);
      if (latitude == null || longitude == null || distanceMeters == null) {
        continue;
      }

      final address =
          _cleanText(item['address']) ??
          '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
      final name = _displayName(_cleanText(item['name']), address);
      if (name == null) {
        continue;
      }
      final mosque = Mosque(
        id: _cleanText(item['id']) ?? '$latitude,$longitude',
        cityId: 'remote',
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      mosques.add(
        MosqueDistance(
          mosque: mosque,
          distanceMeters: distanceMeters,
          usesDeviceLocation: usesDeviceLocation,
        ),
      );
    }

    return mosques;
  }

  String? _displayName(String? rawName, String address) {
    final name = rawName?.replaceAll(RegExp(r'\s*/\s*'), ' / ').trim();
    if (name == null || name.isEmpty) {
      return '${_localityFromAddress(address) ?? 'Yakındaki'} Camii';
    }

    final normalized = name.toLowerCase();
    if (normalized == 'czystanek') {
      return null;
    }

    if (normalized == 'mosque' ||
        normalized == 'masjid' ||
        normalized == 'cami' ||
        normalized == 'camii' ||
        name == 'مسجد') {
      return '${_localityFromAddress(address) ?? 'Yakındaki'} Camii';
    }

    return name;
  }

  String? _localityFromAddress(String address) {
    final districtMatch = RegExp(
      r'([A-Za-zÇĞİÖŞÜçğıöşü]+)\s*/\s*Antalya',
    ).firstMatch(address);
    if (districtMatch != null) {
      return districtMatch.group(1);
    }

    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);
    for (final part in parts) {
      if (part.contains('/')) {
        return part.split('/').first.trim();
      }
    }
    return null;
  }

  double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  String? _cleanText(Object? value) {
    final text = value?.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text == null || text.isEmpty || text == 'Adres bilgisi yok') {
      return null;
    }
    return text;
  }
}
