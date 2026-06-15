import '../../../../../../core/entities/destination_entity.dart';

abstract class DestinationsState {}

class DestinationsInitial extends DestinationsState {}

class DestinationsLoading extends DestinationsState {}

class DestinationsLoaded extends DestinationsState {
  final List<DestinationEntity> destinations;
  DestinationsLoaded(this.destinations);
}

class DestinationsError extends DestinationsState {
  final String message;
  DestinationsError(this.message);
}