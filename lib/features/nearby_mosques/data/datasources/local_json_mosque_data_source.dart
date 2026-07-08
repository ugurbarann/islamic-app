import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/mosque.dart';

class LocalJsonMosqueDataSource {
  const LocalJsonMosqueDataSource({
    this.assetPath = 'assets/data/mock_mosques.json',
  });

  final String assetPath;

  Future<List<Mosque>> loadMosques() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) {
          final map = item as Map<String, dynamic>;
          return Mosque(
            id: map['id'] as String,
            cityId: map['cityId'] as String,
            name: map['name'] as String,
            address: map['address'] as String,
            latitude: (map['latitude'] as num).toDouble(),
            longitude: (map['longitude'] as num).toDouble(),
          );
        })
        .toList(growable: false);
  }
}
