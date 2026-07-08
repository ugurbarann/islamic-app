class QuranReadingPreferences {
  const QuranReadingPreferences({
    this.showTransliteration = true,
    this.showTranslation = true,
    this.arabicTextSize = 29,
    this.translationTextSize = 16,
  });

  final bool showTransliteration;
  final bool showTranslation;
  final double arabicTextSize;
  final double translationTextSize;

  QuranReadingPreferences copyWith({
    bool? showTransliteration,
    bool? showTranslation,
    double? arabicTextSize,
    double? translationTextSize,
  }) {
    return QuranReadingPreferences(
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      arabicTextSize: arabicTextSize ?? this.arabicTextSize,
      translationTextSize: translationTextSize ?? this.translationTextSize,
    );
  }
}
