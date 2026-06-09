

import '../../../../core/entities/booking_entity.dart';
import '../repo interface/traveler_repository.dart';

class GetBookingUseCase {
  final TravelerRepository repo;

  GetBookingUseCase(this.repo);

  Future<BookingEntity> call(String bookingId) {
    return repo.getBooking(bookingId);
  }
}