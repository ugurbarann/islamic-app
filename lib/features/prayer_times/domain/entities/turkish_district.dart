class TurkishDistrict {
  const TurkishDistrict({
    required this.id,
    required this.cityId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.ezanVaktiDistrictId,
  });

  final String id;
  final String cityId;
  final String name;
  final double latitude;
  final double longitude;
  final String? ezanVaktiDistrictId;
}
