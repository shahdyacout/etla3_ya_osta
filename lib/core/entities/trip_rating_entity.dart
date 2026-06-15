
class TripRating {
  final String tripId;
  final String driverId;
  final int stars;         
  final List<String> tags;
  final String? comment;    

  const TripRating({
    required this.tripId,
     required this.driverId,
    required this.stars,
    required this.tags,
    this.comment,
  });
}