import '../../../../core/entities/booking_entity.dart';
import '../../../../core/entities/destination_entity.dart';
import '../../../../core/entities/trip_entity.dart';
import '../entities/direction_step.dart';

abstract class TravelerRepository {
  Future<List<DestinationEntity>> getDestinations();

  Stream<List<TripEntity>> getTripsStream(String destinationId);

  Future<BookingEntity> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
  });

  Future<BookingEntity> createPendingBooking({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
    required double depositAmount,
  });

  Future<void> confirmBooking(String bookingId);

  Future<BookingEntity> getBooking(String bookingId);
  Future<List<DirectionStep>> getLiveDirections();
}
