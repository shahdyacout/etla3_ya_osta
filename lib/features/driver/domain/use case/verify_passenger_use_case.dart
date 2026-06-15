import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class VerifyPassengerUseCase {
  final DriverRepository repository;

  VerifyPassengerUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookingId, String driverId) async {
    return await repository.verifyPassengerBooking(bookingId, driverId);
  }
}
