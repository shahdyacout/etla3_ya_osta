import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../domain/usecases/get_trips_usecase.dart';
import 'trips_state.dart';


class TripsCubit extends Cubit<TripsState> {
  final GetTripsUseCase getTrips;

  TripsCubit(this.getTrips) : super(TripsInitial());

  Future<void> loadTrips(String destinationId) async {
    emit(TripsLoading());

    try {
      final res = await getTrips(destinationId);
      emit(TripsLoaded(res));
    } catch (e) {
      emit(TripsError(e.toString()));
    }
  }
}
