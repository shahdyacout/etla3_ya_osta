import 'package:etla3_ya_osta/features/traveler/domain/entities/direction_step.dart';

import '../../../../core/entities/booking_entity.dart';
import '../../../../core/entities/destination_entity.dart';
import '../../../../core/entities/trip_entity.dart';
import '../../domain/repository/traveler_repository.dart';
import '../datasource/traveler_remote_data_source.dart';

class TravelerRepositoryImpl implements TravelerRepository {
  final TravelerRemoteDataSource remote;

  TravelerRepositoryImpl(this.remote);

  @override
  Future<List<DestinationEntity>> getDestinations() {
    return remote.getDestinations();
  }

  @override
  Stream<List<TripEntity>> getTripsStream(String destinationId) {
    return remote.getTripsStream(destinationId);
  }

  @override
  Future<BookingEntity> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
  }) {
    return remote.bookTrip(
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
      driverId: driverId,
    );
  }

  @override
  Future<BookingEntity> createPendingBooking({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
    required double depositAmount,
  }) {
    return remote.createPendingBooking(
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
      driverId: driverId,
      depositAmount: depositAmount,
    );
  }

  @override
  Future<void> confirmBooking(String bookingId) {
    return remote.confirmBooking(bookingId);
  }

  @override
  Future<BookingEntity> getBooking(String bookingId) {
    return remote.getBooking(bookingId);
  }

  @override
  Future<List<DirectionStep>> getLiveDirections() {
    return remote.getLiveDirections();
  }
}
