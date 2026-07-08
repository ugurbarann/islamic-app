enum PrayerName {
  imsak('imsak', 'İmsak'),
  sunrise('sunrise', 'Güneş'),
  dhuhr('dhuhr', 'Öğle'),
  asr('asr', 'İkindi'),
  maghrib('maghrib', 'Akşam'),
  isha('isha', 'Yatsı');

  const PrayerName(this.jsonKey, this.label);

  final String jsonKey;
  final String label;
}
