import 'package:flutter_test/flutter_test.dart';

import 'package:islamic_app/features/prayer_times/data/models/ezan_vakti_prayer_day_model.dart';
import 'package:islamic_app/features/prayer_times/domain/entities/prayer_name.dart';

void main() {
  test('keeps the Turkish calendar day when the service includes +03:00', () {
    final model = EzanVaktiPrayerDayModel.fromJson(const {
      'MiladiTarihUzunIso8601': '2026-07-12T00:00:00.0000000+03:00',
      'MiladiTarihKisa': '12.07.2026',
      'Imsak': '04:11',
      'Gunes': '05:53',
      'Ogle': '13:21',
      'Ikindi': '17:12',
      'Aksam': '20:39',
      'Yatsi': '22:14',
    });

    expect(model.date, DateTime(2026, 7, 12));
    expect(model.times[PrayerName.imsak], '04:11');
    expect(model.times[PrayerName.maghrib], '20:39');
  });
}
