import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/islamic_knowledge_sample_model.dart';

class LocalJsonIslamicKnowledgeDataSource {
  const LocalJsonIslamicKnowledgeDataSource({
    this.assetPath = 'assets/data/islamic_knowledge_sample.json',
  });

  final String assetPath;

  Future<IslamicKnowledgeSampleModel> loadData() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return IslamicKnowledgeSampleModel.fromJson(json);
  }
}
