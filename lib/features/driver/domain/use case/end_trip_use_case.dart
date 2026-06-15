import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class EndTripUseCase {
  final DriverRepository repository;

  EndTripUseCase(this.repository);

  Future<Either<Failure, void>> call(String tripId, String driverId, int passengers, double earnings) async {
    return await repository.endTrip(tripId, driverId, passengers, earnings);
  }
}
