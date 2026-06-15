import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/rating_repository.dart';

import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';
import 'usecase.dart';

class RateTripUseCase extends UseCase<void, TripRating> {
  final RatingRepository repository;

  RateTripUseCase(this.repository);

  @override
  Future<void> call(TripRating rating) async {
    await repository.submitRating(rating);
  }
}
