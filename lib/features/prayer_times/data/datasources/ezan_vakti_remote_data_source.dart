import 'package:dio/dio.dart';

import '../models/ezan_vakti_district_model.dart';
import '../models/ezan_vakti_prayer_day_model.dart';

class EzanVaktiRemoteDataSource {
  EzanVaktiRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://ezanvakti.emushaf.net',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            ),
          );

  final Dio _dio;

  Future<List<EzanVaktiDistrictModel>> loadDistricts(String cityId) async {
    final response = await _dio.get<List<dynamic>>('/ilceler/$cityId');
    final data = response.data ?? const [];
    return data
        .map(
          (json) =>
              EzanVaktiDistrictModel.fromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<List<EzanVaktiPrayerDayModel>> loadPrayerTimes(
    String districtId,
  ) async {
    final response = await _dio.get<List<dynamic>>('/vakitler/$districtId');
    final data = response.data ?? const [];
    return data
        .map(
          (json) =>
              EzanVaktiPrayerDayModel.fromJson(json as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}
