import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../repo interface/i_wallet_repository.dart';

class WithdrawFundsUseCase {
  final IWalletRepository repository;
  WithdrawFundsUseCase(this.repository);

  Future<Either<Failure, void>> call(double amount) {
    if (amount <= 0) {
      return Future.value(
        const Left(InvalidInputFailure('Amount must be greater than zero')),
      );
    }
    return repository.withdrawFunds(amount);
  }
}