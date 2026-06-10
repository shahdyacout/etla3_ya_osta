import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../entities/transaction_entities.dart';
import '../repo interface/i_wallet_repository.dart';

class GetTransactionsUseCase {
  final IWalletRepository repository;
  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call() {
    return repository.getTransactions();
  }
}