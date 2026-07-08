class FridayReminderPreference {
  const FridayReminderPreference({
    required this.enabled,
    this.hour = 10,
    this.minute = 0,
  });

  final bool enabled;
  final int hour;
  final int minute;
}
