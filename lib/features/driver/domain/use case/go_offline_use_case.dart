import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class GoOfflineUseCase {
  final DriverRepository repository;

  GoOfflineUseCase(this.repository);

  Future<Either<Failure, void>> call(String driverId) async {
    return await repository.goOffline(driverId);
  }
}
