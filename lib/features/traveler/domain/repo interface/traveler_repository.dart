import '../../../../core/entities/booking_entity.dart';
import '../../../../core/entities/destination_entity.dart';
import '../../../../core/entities/trip_entity.dart';

abstract class TravelerRepository {
  Future<List<DestinationEntity>> getDestinations();

  Future<List<TripEntity>> getTrips(String destinationId);

  Future<BookingEntity> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  });

  Future<BookingEntity> getBooking(String bookingId);
}