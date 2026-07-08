import 'turkish_district.dart';

class TurkishCity {
  const TurkishCity({
    required this.id,
    required this.name,
    required this.districts,
    this.ezanVaktiCityId,
  });

  final String id;
  final String name;
  final List<TurkishDistrict> districts;
  final String? ezanVaktiCityId;
}
