import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/rating_repository.dart';
import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore firestore;

  RatingRepositoryImpl(this.firestore);

  @override
  Future<void> submitRating(TripRating rating) async {
    final driverRef = firestore.collection('drivers').doc(rating.driverId);
    final driverSnap = await driverRef.get();
    final data = driverSnap.data();
    final currentAvg = (data?['avgRating'] as num?)?.toDouble() ?? 0.0;
    final totalRatings = (data?['totalRatings'] as int?) ?? 0;
    final newTotal = totalRatings + 1;
    final newAvg = ((currentAvg * totalRatings) + rating.stars) / newTotal;

    final batch = firestore.batch();

    final ratingRef = firestore.collection('ratings').doc();
    batch.set(ratingRef, {
      'tripId': rating.tripId,
      'driverId': rating.driverId,
      'travelerId': rating.travelerId,
      'stars': rating.stars,
      'tags': rating.tags,
      'comment': rating.comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(driverRef, {
      'avgRating': double.parse(newAvg.toStringAsFixed(1)),
      'totalRatings': newTotal,
    });

    await batch.commit();
  }
}
