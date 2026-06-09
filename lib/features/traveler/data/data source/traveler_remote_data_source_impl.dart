import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/destination_dto.dart';
import '../dto/trip_dto.dart';
import 'traveler_remote_data_source.dart';


class TravelerRemoteDataSourceImpl implements TravelerRemoteDataSource {
  final FirebaseFirestore firestore;

  TravelerRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<DestinationDto>> getDestinations() async {
    final res = await firestore.collection('destinations').get();

    return res.docs
        .map((e) => DestinationDto.fromJson(e.id, e.data()))
        .toList();
  }

  @override
  Future<List<TripDto>> getTrips(String destinationId) async {
    final res = await firestore
        .collection('trips')
        .where('destinationId', isEqualTo: destinationId)
        .get();

    return res.docs
        .map((e) => TripDto.fromJson(e.id, e.data()))
        .toList();
  }

  @override
  Future<void> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) async {
    final bookingRef = firestore.collection('bookings').doc();

    await bookingRef.set({
      "bookingId": bookingRef.id,
      "tripId": tripId,
      "travelerId": travelerId,
      "seatNumber": seatNumber,
      "status": "confirmed",
      "createdAt": FieldValue.serverTimestamp(),
    });

    await firestore.collection('trips').doc(tripId).update({
      "availableSeats": FieldValue.increment(-1),
      "occupiedSeats": FieldValue.increment(1),
    });
  }
}