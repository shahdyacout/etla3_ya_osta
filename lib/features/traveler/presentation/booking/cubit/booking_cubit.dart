import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/booking_entity.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../domain/usecases/book_trip_usecase.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookTripUseCase bookTrip;

  BookingCubit(this.bookTrip) : super(BookingInitial());

  void init(TripEntity trip) {
    emit(
      BookingLoaded(
        trip: trip,
      ),
    );
  }

  void changeSeats(int seats) {
    final current = state;

    if (current is BookingLoaded) {
      if (seats < 1) return;

      if (seats > current.trip.availableSeats) return;

      emit(
          current.copyWith(
            selectedSeats: seats,
          )
      );

    }
  }

  Future<BookingEntity?> createPendingBooking({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
    required double depositAmount,
  }) async {
    final current = state;
    if (current is! BookingLoaded) return null;

    emit(BookingLoading(current));

    try {
      final booking = await bookTrip.createPending(
        tripId: tripId,
        travelerId: travelerId,
        seatNumber: seatNumber,
        driverId: driverId,
        depositAmount: depositAmount,
      );

      emit(current);
      return booking;
    } catch (e) {
      emit(current);
      return null;
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      await bookTrip.confirmBooking(bookingId);
    } catch (e) {
      // Silent fail - booking will be confirmed by webhook
    }
  }

  Future<void> book({
    required String tripId,
    required String travelerId,
    required int seatNumber,
    required String driverId,
  }) async {
    final current = state;

    if (current is! BookingLoaded) return;

    emit(BookingLoading(current));

    try {
      final booking = await bookTrip(
        tripId: tripId,
        travelerId: travelerId,
        seatNumber: seatNumber,
        driverId: driverId,
      );

      emit(BookingSuccess(booking));
    } catch (e) {
      emit(current);

      emit(
        BookingError(
          e.toString(),
        ),
      );
    }
  }

}