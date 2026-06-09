
import '../dto/destination_dto.dart';
import '../dto/trip_dto.dart';

abstract class TravelerRemoteDataSource {
  Future<List<DestinationDto>> getDestinations();

  Future<List<TripDto>> getTrips(String destinationId);

  Future<void> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  });
}