import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/rating_repository.dart';

import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';

class RatingRepositoryImpl implements RatingRepository {
  @override
  Future<void> submitRating(TripRating rating) async {
    // مؤقتاً بس print — هنبعته لـ API لاحقاً
    await Future.delayed(const Duration(milliseconds: 500));

    print('Rating submitted: ${rating.stars} stars for trip ${rating.tripId}');
  }
}
