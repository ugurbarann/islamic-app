class AppThemePreference {
  const AppThemePreference({this.darkModeEnabled = false});

  final bool darkModeEnabled;

  AppThemePreference copyWith({bool? darkModeEnabled}) {
    return AppThemePreference(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}
