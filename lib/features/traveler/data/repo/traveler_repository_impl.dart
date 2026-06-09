

import '../../../../core/entities/booking_entity.dart';
import '../../../../core/entities/destination_entity.dart';
import '../../../../core/entities/trip_entity.dart';
import '../../domain/repo interface/traveler_repository.dart';
import '../data source/traveler_remote_data_source.dart';

class TravelerRepositoryImpl implements TravelerRepository {
  final TravelerRemoteDataSource remote;

  TravelerRepositoryImpl(this.remote);

  @override
  Future<List<DestinationEntity>> getDestinations() {
    return remote.getDestinations();
  }

  @override
  Future<List<TripEntity>> getTrips(String destinationId) {
    return remote.getTrips(destinationId);
  }

  @override
  Future<void> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) {
    return remote.bookTrip(
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
    );
  }

  @override
  Future<BookingEntity> getBooking(String bookingId) {
    throw UnimplementedError();
  }
}