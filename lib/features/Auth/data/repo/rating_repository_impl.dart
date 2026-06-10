import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/rating_repository.dart';

import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';

class RatingRepositoryImpl implements RatingRepository {
  @override
  Future<void> submitRating(TripRating rating) async {
    // مؤقتاً بس سيتم إرسالها لـ API لاحقاً
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Integrate with API endpoint to submit rating
    // Currently just simulating the delay
  }
}
