import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../entities/wallet_entities.dart';
import '../repo interface/i_wallet_repository.dart';

class GetBalanceUseCase {
  final IWalletRepository repository;
  GetBalanceUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call() {
    return repository.getBalance();
  }
}