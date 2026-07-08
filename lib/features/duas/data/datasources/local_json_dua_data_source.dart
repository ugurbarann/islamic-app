import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dua_category_model.dart';

class LocalJsonDuaDataSource {
  const LocalJsonDuaDataSource({
    this.assetPath = 'assets/data/duas_sample.json',
  });

  final String assetPath;

  Future<List<DuaCategoryModel>> loadData() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => DuaCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }
}
