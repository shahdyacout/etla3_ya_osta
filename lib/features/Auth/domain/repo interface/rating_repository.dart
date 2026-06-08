import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';

abstract class RatingRepository {
  Future<void> submitRating(TripRating rating);
}
