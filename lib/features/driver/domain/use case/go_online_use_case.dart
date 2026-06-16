import 'package:dartz/dartz.dart';
import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class GoOnlineUseCase {
  final DriverRepository repository;

  GoOnlineUseCase(this.repository);

  Future<Either<Failure, void>> call(String driverId) async {
    return await repository.goOnline(driverId);
  }
}
