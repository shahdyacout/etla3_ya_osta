class DirectionStep {
  final String text;
  final String distance;
  final String status; // 'done', 'current', 'pending'

  const DirectionStep({
    required this.text,
    required this.distance,
    required this.status,
  });

  // ميثود لنسخ الكائن مع تغيير الحالة (مفيدة للـ Cubit)
  DirectionStep copyWith({String? status}) {
    return DirectionStep(
      text: text,
      distance: distance,
      status: status ?? this.status,
    );
  }
}