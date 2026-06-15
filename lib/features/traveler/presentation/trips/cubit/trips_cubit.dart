import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../domain/usecases/get_trips_usecase.dart';
import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final GetTripsUseCase getTrips;

  StreamSubscription<List<TripEntity>>? _tripsSubscription;

  TripsCubit(this.getTrips) : super(TripsInitial());

  void loadTrips(String destinationId) {
    _tripsSubscription?.cancel();
    emit(TripsLoading());

    _tripsSubscription = getTrips(destinationId).listen(
      (trips) => emit(TripsLoaded(trips)),
      onError: (e) => emit(TripsError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _tripsSubscription?.cancel();
    return super.close();
  }
}
