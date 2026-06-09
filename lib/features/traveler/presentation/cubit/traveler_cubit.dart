import 'package:etla3_ya_osta/features/traveler/presentation/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/book_trip_usecase.dart';
import '../../domain/usecase/get_destinations_usecase.dart';
import '../../domain/usecase/get_trips_usecase.dart';

class TravelerCubit extends Cubit<TravelerState> {
  final GetDestinationsUseCase getDestinations;
  final GetTripsUseCase getTrips;
  final BookTripUseCase bookTrip;

  TravelerCubit(
      this.getDestinations,
      this.getTrips,
      this.bookTrip,
      ) : super(TravelerInitial());

  Future<void> loadDestinations() async {
    emit(DestinationsLoading()); // تعديل هنا
    try {
      final res = await getDestinations();
      emit(DestinationsLoaded(res));
    } catch (e) {
      emit(DestinationsError(e.toString())); // تعديل هنا
    }
  }

  Future<void> loadTrips(String destinationId) async {
    emit(TripsLoading()); // تعديل هنا
    try {
      final res = await getTrips(destinationId);
      emit(TripsLoaded(res));
    } catch (e) {
      emit(TripsError(e.toString())); // تعديل هنا
    }
  }

  Future<void> book({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) async {
    emit(BookingLoading()); // تعديل هنا
    try {
      await bookTrip(
        tripId: tripId,
        travelerId: travelerId,
        seatNumber: seatNumber,
      );
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingError(e.toString())); // تعديل هنا
    }
  }
}