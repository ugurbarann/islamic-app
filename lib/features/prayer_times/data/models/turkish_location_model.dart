import '../../domain/entities/turkish_city.dart';
import '../../domain/entities/turkish_district.dart';

class TurkishLocationModel {
  const TurkishLocationModel({required this.city, required this.districts});

  factory TurkishLocationModel.fromJson(Map<String, dynamic> json) {
    final cityId = json['id'] as String;
    final districts = (json['districts'] as List<dynamic>)
        .map(
          (districtJson) => TurkishDistrict(
            id: districtJson['id'] as String,
            cityId: cityId,
            name: districtJson['name'] as String,
            latitude: (districtJson['latitude'] as num).toDouble(),
            longitude: (districtJson['longitude'] as num).toDouble(),
            ezanVaktiDistrictId: districtJson['ezanVaktiDistrictId'] as String?,
          ),
        )
        .toList(growable: false);

    return TurkishLocationModel(
      city: TurkishCity(
        id: cityId,
        name: json['name'] as String,
        districts: districts,
        ezanVaktiCityId: json['ezanVaktiCityId'] as String?,
      ),
      districts: districts,
    );
  }

  final TurkishCity city;
  final List<TurkishDistrict> districts;
}
