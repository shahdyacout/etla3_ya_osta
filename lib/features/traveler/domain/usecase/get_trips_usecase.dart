import '../../../../core/entities/trip_entity.dart';
import '../repo interface/traveler_repository.dart';

class GetTripsUseCase {
  final TravelerRepository repo;

  GetTripsUseCase(this.repo);

  Future<List<TripEntity>> call(String destinationId) {
    return repo.getTrips(destinationId);
  }
}
