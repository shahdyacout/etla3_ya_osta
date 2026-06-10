import '../dto/booking_dto.dart';
import '../dto/destination_dto.dart';
import '../dto/trip_dto.dart';

abstract class TravelerRemoteDataSource {
  Future<List<DestinationDto>> getDestinations();

  Future<List<TripDto>> getTrips(String destinationId);

  Future<BookingDto> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  });

  Future<BookingDto> getBooking(String bookingId);
}
