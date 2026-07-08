import '../../domain/entities/turkish_district.dart';

class EzanVaktiDistrictModel {
  const EzanVaktiDistrictModel({
    required this.name,
    required this.nameEn,
    required this.id,
  });

  factory EzanVaktiDistrictModel.fromJson(Map<String, dynamic> json) {
    return EzanVaktiDistrictModel(
      name: json['IlceAdi'] as String,
      nameEn: json['IlceAdiEn'] as String? ?? json['IlceAdi'] as String,
      id: json['IlceID'] as String,
    );
  }

  final String name;
  final String nameEn;
  final String id;

  TurkishDistrict toEntity({
    required String cityId,
    required double fallbackLatitude,
    required double fallbackLongitude,
  }) {
    final normalizedId = _slugify('${cityId}_$id');
    return TurkishDistrict(
      id: normalizedId,
      cityId: cityId,
      name: _titleCase(name),
      latitude: fallbackLatitude,
      longitude: fallbackLongitude,
      ezanVaktiDistrictId: id,
    );
  }

  static String _titleCase(String value) {
    return value
        .toLowerCase()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String _slugify(String value) {
    const replacements = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'i̇': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
    };
    var output = value.toLowerCase();
    for (final entry in replacements.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+$'), '');
  }
}
