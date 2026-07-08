class Surah {
  const Surah({
    required this.number,
    required this.nameTurkish,
    required this.nameArabic,
    required this.ayahCount,
    this.revelationType,
  });

  final int number;
  final String nameTurkish;
  final String nameArabic;
  final int ayahCount;
  final String? revelationType;
}
