import '../../../../core/entities/trip_entity.dart';
import '../repository/traveler_repository.dart';

class GetTripsUseCase {
  final TravelerRepository repo;

  GetTripsUseCase(this.repo);

  Stream<List<TripEntity>> call(String destinationId) {
    return repo.getTripsStream(destinationId);
  }
}
