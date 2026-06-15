
import '../../../domain/entities/direction_step.dart';

abstract class DirectionsState {}

class DirectionsInitial extends DirectionsState {}
class DirectionsLoading extends DirectionsState {}
class DirectionsLoaded extends DirectionsState {
  final List<DirectionStep> steps;
  DirectionsLoaded(this.steps);
}
class DirectionsError extends DirectionsState {
  final String message;
  DirectionsError(this.message);
}