import '../../../../core/entities/booking_entity.dart';
import '../repo interface/traveler_repository.dart';

class BookTripUseCase {
  final TravelerRepository repo;

  BookTripUseCase(this.repo);

  Future<BookingEntity> call({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) {
    return repo.bookTrip(
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
    );
  }
}

