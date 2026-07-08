enum DailyContentType {
  ayah('ayah'),
  hadith('hadith'),
  dua('dua'),
  knowledge('knowledge'),
  quote('quote'),
  surahHighlight('surah_highlight');

  const DailyContentType(this.jsonKey);

  final String jsonKey;

  static DailyContentType? fromJsonKey(String value) {
    for (final type in values) {
      if (type.jsonKey == value) {
        return type;
      }
    }
    return null;
  }
}
