class Dua {
  const Dua({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.turkishText,
    this.arabicText,
    this.turkishTransliteration,
    this.source,
  });

  final String id;
  final String categoryId;
  final String title;
  final String turkishText;
  final String? arabicText;
  final String? turkishTransliteration;
  final String? source;
}
