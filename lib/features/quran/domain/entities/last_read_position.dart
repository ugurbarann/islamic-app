class LastReadPosition {
  const LastReadPosition({
    required this.surahNumber,
    required this.ayahNumber,
    required this.updatedAt,
  });

  final int surahNumber;
  final int ayahNumber;
  final DateTime updatedAt;

  String get ayahId => '$surahNumber:$ayahNumber';
}
