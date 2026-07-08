class TasbihSession {
  const TasbihSession({
    required this.id,
    required this.count,
    required this.savedAt,
    this.title = 'Tesbih',
  });

  final String id;
  final String title;
  final int count;
  final DateTime savedAt;
}
