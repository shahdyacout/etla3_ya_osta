import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../Core/error/failures.dart';
import '../../domain/entities/earning_entities.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/entities/wallet_entities.dart';
import '../../domain/repo interface/i_wallet_repository.dart';
import '../data source/wallet_firestore_ds.dart';

class WalletRepositoryImpl implements IWalletRepository {
  final WalletFirestoreDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  Failure _handleException(Object e) {
    if (e is Failure) return e;

    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure();
        case 'permission-denied':
          return const AuthFailure();
        default:
          return ServerFailure(e.message ?? 'Firebase error');
      }
    }

    if (e is FormatException) {
      return ServerFailure(e.message);
    }

    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, WalletEntity>> getBalance() async {
    try {
      final wallet = await _dataSource.getWallet();
      return Right(wallet);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, EarningsEntity>> getEarnings() async {
    try {
      final earnings = await _dataSource.getEarnings();
      return Right(earnings);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final transactions = await _dataSource.getTransactions();
      return Right(transactions);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawFunds(double amount) async {
    try {
      await _dataSource.withdrawFunds(amount);
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}