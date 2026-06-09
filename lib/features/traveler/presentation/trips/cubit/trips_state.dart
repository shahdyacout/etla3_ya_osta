
import '../../../../../core/entities/trip_entity.dart';

abstract class TripsState {}

class TripsInitial extends TripsState {}

class TripsLoading extends TripsState {}

class TripsLoaded extends TripsState {
  final List<TripEntity> trips;
  TripsLoaded(this.trips);
}

class TripsError extends TripsState {
  final String message;
  TripsError(this.message);
}