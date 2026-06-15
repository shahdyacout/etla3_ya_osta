import '../entities/direction_step.dart';
import '../repository/traveler_repository.dart';

class GetLiveDirectionsUseCase {
  final TravelerRepository repo;

  GetLiveDirectionsUseCase(this.repo);

  Future<List<DirectionStep>> call() {
    return repo.getLiveDirections();
  }
}
