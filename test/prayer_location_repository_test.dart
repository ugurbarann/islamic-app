import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:islamic_app/features/prayer_times/data/datasources/ezan_vakti_remote_data_source.dart';
import 'package:islamic_app/features/prayer_times/data/datasources/local_json_prayer_location_data_source.dart';
import 'package:islamic_app/features/prayer_times/data/datasources/prayer_times_cache_data_source.dart';
import 'package:islamic_app/features/prayer_times/data/repositories/shared_preferences_prayer_location_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'maps a saved local Bodrum selection to its live prayer-time id',
    () async {
      SharedPreferences.setMockInitialValues({
        'selected_prayer_city_id': 'mugla',
        'selected_prayer_district_id': 'bodrum',
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/ilceler/558');
              handler.resolve(
                Response<List<dynamic>>(
                  requestOptions: options,
                  data: const [
                    {
                      'IlceAdi': 'BODRUM',
                      'IlceAdiEn': 'BODRUM',
                      'IlceID': '9741',
                    },
                    {
                      'IlceAdi': 'MUĞLA',
                      'IlceAdiEn': 'MUGLA',
                      'IlceID': '9676',
                    },
                  ],
                ),
              );
            },
          ),
        );
      final repository = SharedPreferencesPrayerLocationRepository(
        dataSource: const LocalJsonPrayerLocationDataSource(),
        remoteDataSource: EzanVaktiRemoteDataSource(dio: dio),
        cacheDataSource: const PrayerTimesCacheDataSource(),
      );

      final location = await repository.loadSelectedLocation();

      expect(location.city.name, 'Muğla');
      expect(location.district.name, 'Bodrum');
      expect(location.district.ezanVaktiDistrictId, '9741');
    },
  );
}
