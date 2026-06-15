
class TripRating {
  final String tripId;
  final String driverId;
  final String travelerId;
  final int stars;
  final List<String> tags;
  final String? comment;

  const TripRating({
    required this.tripId,
    required this.driverId,
    required this.travelerId,
    required this.stars,
    required this.tags,
    this.comment,
  });
}