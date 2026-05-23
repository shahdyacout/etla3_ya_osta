import '../entities/trip_rating.dart';

abstract class RatingRepository {
  Future<void> submitRating(TripRating rating);
}