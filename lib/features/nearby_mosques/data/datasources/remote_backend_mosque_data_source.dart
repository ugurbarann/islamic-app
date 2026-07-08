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

        return _parseMosques(
          response.data?['items'],
          limit: limit,
          usesDeviceLocation: usesDeviceLocation,
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    return const [];
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
      final mosque = Mosque(
        id: _cleanText(item['id']) ?? '$latitude,$longitude',
        cityId: 'remote',
        name: _cleanText(item['name']) ?? 'Cami',
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
