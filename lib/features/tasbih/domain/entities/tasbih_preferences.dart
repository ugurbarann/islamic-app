class TasbihPreferences {
  const TasbihPreferences({this.hapticFeedbackEnabled = true});

  final bool hapticFeedbackEnabled;

  TasbihPreferences copyWith({bool? hapticFeedbackEnabled}) {
    return TasbihPreferences(
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}
