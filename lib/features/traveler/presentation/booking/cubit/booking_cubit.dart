import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../domain/usecase/book_trip_usecase.dart';
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
        BookingLoaded(
          trip: current.trip,
          selectedSeats: seats,
        ),
      );

    }
  }

  Future<void> book({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) async {
    final current = state;

    if (current is! BookingLoaded) return;

    emit(BookingLoading(current));

    try {
      final booking = await bookTrip(
        tripId: tripId,
        travelerId: travelerId,
        seatNumber: seatNumber,
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