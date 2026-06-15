import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:etla3_ya_osta/features/Auth/domain/repo%20interface/rating_repository.dart';
import 'package:etla3_ya_osta/core/entities/trip_rating_entity.dart';

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> submitRating(TripRating rating) async {
    final travelerId = _firebaseAuth.currentUser?.uid ?? '';

    final ratingData = {
      'tripId': rating.tripId,
      'driverId': rating.driverId,
      'travelerId': travelerId,
      'stars': rating.stars,
      'tags': rating.tags,
      'comment': rating.comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // بنحفظ التقييم تحت السواق عشان يقدر يشوفه
    await _firestore
        .collection('users')
        .doc(rating.driverId)
        .collection('ratings')
        .add(ratingData);

    // وبنحفظه كمان في collection عام للتقارير
    await _firestore.collection('ratings').add(ratingData);
  }
}