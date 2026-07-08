import 'turkish_city.dart';
import 'turkish_district.dart';

class SelectedPrayerLocation {
  const SelectedPrayerLocation({required this.city, required this.district});

  final TurkishCity city;
  final TurkishDistrict district;
}
