import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';

class QuranSurahIndexModel {
  const QuranSurahIndexModel({required this.surah});

  factory QuranSurahIndexModel.fromJson(Map<String, dynamic> json) {
    return QuranSurahIndexModel(surah: surahFromJson(json));
  }

  final Surah surah;
}

class QuranSampleModel {
  const QuranSampleModel({required this.surah, required this.ayahs});

  factory QuranSampleModel.fromJson(Map<String, dynamic> json) {
    final surahNumber = json['number'] as int;
    final ayahs = (json['ayahs'] as List<dynamic>)
        .map((ayahJson) {
          final ayahMap = ayahJson as Map<String, dynamic>;
          final ayahNumber = ayahMap['number'] as int;
          return Ayah(
            id: '$surahNumber:$ayahNumber',
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            arabicText: ayahMap['arabicText'] as String,
            turkishTransliteration:
                ayahMap['turkishTransliteration'] as String?,
            turkishTranslation: ayahMap['turkishTranslation'] as String,
          );
        })
        .toList(growable: false);

    return QuranSampleModel(
      surah: surahFromJson(json, fallbackAyahCount: ayahs.length),
      ayahs: ayahs,
    );
  }

  final Surah surah;
  final List<Ayah> ayahs;
}

Surah surahFromJson(Map<String, dynamic> json, {int? fallbackAyahCount}) {
  return Surah(
    number: json['number'] as int,
    nameTurkish: json['nameTurkish'] as String,
    nameArabic: json['nameArabic'] as String,
    ayahCount: json['ayahCount'] as int? ?? fallbackAyahCount ?? 0,
    revelationType: json['revelationType'] as String?,
  );
}
