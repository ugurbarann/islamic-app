import '../../domain/entities/prayer_name.dart';

String formatClock(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatRemaining(Duration value) {
  final duration = value.isNegative ? Duration.zero : value;
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String prayerStatusLabel({
  required PrayerName prayerName,
  required PrayerName? currentPrayerName,
  required PrayerName nextPrayerName,
}) {
  if (prayerName == nextPrayerName) {
    return 'Sıradaki';
  }

  if (prayerName == currentPrayerName) {
    return 'Şu an';
  }

  return '';
}
