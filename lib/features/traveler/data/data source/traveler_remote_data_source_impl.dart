import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/booking_dto.dart';
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

    return res.docs.map((e) => TripDto.fromJson(e.id, e.data())).toList();
  }

  @override
  Future<BookingDto> bookTrip({
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

    await firestore.runTransaction((transaction) async {
      final tripRef = firestore.collection('trips').doc(tripId);

      final tripSnapshot = await transaction.get(tripRef);

      final availableSeats = tripSnapshot['availableSeats'];

      if (seatNumber > availableSeats) {
        throw Exception('Only $availableSeats seats available');
      }

      transaction.update(tripRef, {
        'availableSeats': availableSeats - seatNumber,
        'occupiedSeats': tripSnapshot['occupiedSeats'] + seatNumber,
      });
    });

    return BookingDto(
      bookingId: bookingRef.id,
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
      status: "confirmed",
      createdAt: DateTime.now(),
    );
  }
}
