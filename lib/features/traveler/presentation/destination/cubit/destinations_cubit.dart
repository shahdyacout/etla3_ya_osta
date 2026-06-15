import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/entities/destination_entity.dart';
import '../../../domain/usecases/get_destinations_usecase.dart';
import 'destinations_state.dart';

class DestinationsCubit extends Cubit<DestinationsState> {
  final GetDestinationsUseCase getDestinations;

  DestinationsCubit(this.getDestinations) : super(DestinationsInitial());

  List<DestinationEntity> _allDestinations = [];

  Future<void> loadDestinations() async {
    emit(DestinationsLoading());

    try {
      final res = await getDestinations();

      _allDestinations = res;

      emit(DestinationsLoaded(res));
    } catch (e) {
      emit(DestinationsError(e.toString()));
    }
  }

  void searchDestinations(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      emit(DestinationsLoaded(_allDestinations));
      return;
    }

    final filtered = _allDestinations.where((d) {
      return d.name.toLowerCase().contains(q) ||
          (d.nameEn ?? '').toLowerCase().contains(q);
    }).toList();

    emit(DestinationsLoaded(filtered));
  }
}