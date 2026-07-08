import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';

class RemoteReverseGeocodeDataSource {
  RemoteReverseGeocodeDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 2),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio _dio;

  Future<ResolvedAdministrativeLocation?> resolve({
    required double latitude,
    required double longitude,
  }) async {
    Object? lastError;

    for (final baseUrl in AppConfig.mosqueBackendBaseUrls) {
      try {
        final response = await _dio.getUri<Map<String, dynamic>>(
          Uri.parse(baseUrl).replace(
            path: '/api/reverse-geocode',
            queryParameters: {
              'lat': latitude.toString(),
              'lng': longitude.toString(),
            },
          ),
        );

        final data = response.data;
        if (data == null) {
          continue;
        }

        return ResolvedAdministrativeLocation(
          city: data['city']?.toString(),
          district: data['district']?.toString(),
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    return null;
  }
}

class ResolvedAdministrativeLocation {
  const ResolvedAdministrativeLocation({this.city, this.district});

  final String? city;
  final String? district;
}
