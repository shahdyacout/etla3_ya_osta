import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../entities/earning_entities.dart';
import '../repo interface/i_wallet_repository.dart';

class GetEarningsUseCase {
  final IWalletRepository repository;
  GetEarningsUseCase(this.repository);

  Future<Either<Failure, EarningsEntity>> call() {
    return repository.getEarnings();
  }
}