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

    try {
      final response = await _dio.getUri<Map<String, dynamic>>(
        Uri.parse(AppConfig.reverseGeocodeBaseUrl).replace(
          path: '/reverse',
          queryParameters: {
            'lat': latitude.toString(),
            'lon': longitude.toString(),
            'format': 'jsonv2',
            'addressdetails': '1',
            'accept-language': 'tr',
          },
        ),
        options: Options(
          headers: const {'User-Agent': 'IslamiCep/1.0.5'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final addressValue = response.data?['address'];
      final address = addressValue is Map
          ? addressValue.cast<String, dynamic>()
          : null;
      if (address != null) {
        return ResolvedAdministrativeLocation(
          city: _firstText([
            address['province'],
            address['state'],
            address['city'],
          ]),
          district: _firstText([
            address['district'],
            address['county'],
            address['town'],
            address['municipality'],
          ]),
        );
      }
    } on Object catch (error) {
      lastError = error;
    }

    if (lastError != null) {
      throw lastError;
    }
    return null;
  }

  String? _firstText(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}

class ResolvedAdministrativeLocation {
  const ResolvedAdministrativeLocation({this.city, this.district});

  final String? city;
  final String? district;
}
