import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class UpdateTripStatusUseCase {
  final DriverRepository repository;

  UpdateTripStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String tripId, String status) async {
    return await repository.updateTripStatus(tripId, status);
  }
}
