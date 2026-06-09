import '../../../../core/entities/destination_entity.dart';
import '../../../../core/entities/trip_entity.dart';

abstract class TravelerState {}

class TravelerInitial extends TravelerState {}

// --- حالات الوجهات (Destinations) ---
class DestinationsLoading extends TravelerState {}
class DestinationsLoaded extends TravelerState {
  final List<DestinationEntity> destinations;
  DestinationsLoaded(this.destinations);
}
class DestinationsError extends TravelerState {
  final String message;
  DestinationsError(this.message);
}

// --- حالات الرحلات (Trips) ---
class TripsLoading extends TravelerState {}
class TripsLoaded extends TravelerState {
  final List<TripEntity> trips;
  TripsLoaded(this.trips);
}
class TripsError extends TravelerState {
  final String message;
  TripsError(this.message);
}

// --- حالات الحجز (Booking) ---
class BookingLoading extends TravelerState {}
class BookingSuccess extends TravelerState {}
class BookingError extends TravelerState {
  final String message;
  BookingError(this.message);
}