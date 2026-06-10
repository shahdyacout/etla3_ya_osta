import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../entities/earning_entities.dart';
import '../entities/transaction_entities.dart';
import '../entities/wallet_entities.dart';

abstract class IWalletRepository {
  Future<Either<Failure, WalletEntity>> getBalance();
  Future<Either<Failure, EarningsEntity>> getEarnings();
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, void>> withdrawFunds(double amount);
}