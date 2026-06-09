
import '../../../../core/entities/destination_entity.dart';
import '../repo interface/traveler_repository.dart';

class GetDestinationsUseCase {
  final TravelerRepository repo;

  GetDestinationsUseCase(this.repo);

  Future<List<DestinationEntity>> call() {
    return repo.getDestinations();
  }
}