import '../../../../../core/entities/booking_entity.dart';
import '../../../../../core/entities/trip_entity.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoaded extends BookingState {
  final TripEntity trip;
  final int selectedSeats;
  final String? error;

  BookingLoaded({required this.trip, this.selectedSeats = 1, this.error});

  BookingLoaded copyWith({TripEntity? trip, int? selectedSeats}) {
    return BookingLoaded(
      trip: trip ?? this.trip,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }

  double get total => trip.price * selectedSeats;
}

class BookingLoading extends BookingState {
  final BookingLoaded previousData;

  BookingLoading(this.previousData);
}

class BookingSuccess extends BookingState {
  final BookingEntity booking;

  BookingSuccess(this.booking);
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}
