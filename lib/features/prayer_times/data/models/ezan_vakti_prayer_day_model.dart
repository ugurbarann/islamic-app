import '../../domain/entities/prayer_name.dart';
import '../../domain/entities/prayer_time_day.dart';
import '../../domain/entities/selected_prayer_location.dart';

class EzanVaktiPrayerDayModel {
  const EzanVaktiPrayerDayModel({required this.date, required this.times});

  factory EzanVaktiPrayerDayModel.fromJson(Map<String, dynamic> json) {
    return EzanVaktiPrayerDayModel(
      date: _parseDate(json),
      times: {
        PrayerName.imsak: json['Imsak'] as String,
        PrayerName.sunrise: json['Gunes'] as String,
        PrayerName.dhuhr: json['Ogle'] as String,
        PrayerName.asr: json['Ikindi'] as String,
        PrayerName.maghrib: json['Aksam'] as String,
        PrayerName.isha: json['Yatsi'] as String,
      },
    );
  }

  factory EzanVaktiPrayerDayModel.fromCacheJson(Map<String, dynamic> json) {
    final timesJson = json['times'] as Map<String, dynamic>;
    return EzanVaktiPrayerDayModel(
      date: DateTime.parse(json['date'] as String),
      times: {
        for (final prayerName in PrayerName.values)
          prayerName: timesJson[prayerName.jsonKey] as String,
      },
    );
  }

  final DateTime date;
  final Map<PrayerName, String> times;

  Map<String, dynamic> toCacheJson() {
    return {
      'date': _dateKey(date),
      'times': {
        for (final entry in times.entries) entry.key.jsonKey: entry.value,
      },
    };
  }

  PrayerTimeDay toEntity(SelectedPrayerLocation location) {
    return PrayerTimeDay(
      date: date,
      location: location,
      times: {
        for (final entry in times.entries)
          entry.key: _parseTime(date, entry.value),
      },
    );
  }

  bool matchesDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    final isoValue = json['MiladiTarihUzunIso8601'] as String?;
    if (isoValue != null && isoValue.isNotEmpty) {
      final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(isoValue);
      if (match != null) {
        return DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
      }
    }

    final shortValue =
        (json['MiladiTarihKisaIso8601'] as String?) ??
        json['MiladiTarihKisa'] as String;
    final parts = shortValue.split('.');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  static DateTime _parseTime(DateTime date, String value) {
    final parts = value.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
