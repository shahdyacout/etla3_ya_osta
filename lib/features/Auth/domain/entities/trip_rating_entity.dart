class TripRating {
  final String tripId;
  final int stars;
  final List<String> tags;
  final String? comment;

  const TripRating({
    required this.tripId,
    required this.stars,
    required this.tags,
    this.comment,
  });
}
