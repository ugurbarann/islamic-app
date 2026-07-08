class Ayah {
  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.turkishTranslation,
    this.turkishTransliteration,
  });

  final String id;
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String? turkishTransliteration;
  final String turkishTranslation;
}
