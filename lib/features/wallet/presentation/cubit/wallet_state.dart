import '../../../../Core/error/failures.dart';
import '../../domain/entities/earning_entities.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/entities/wallet_entities.dart';

class WalletState {
  final WalletEntity? wallet;
  final EarningsEntity? earnings;
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final bool isWithdrawing;
  final Failure? failure;

  const WalletState({
    this.wallet,
    this.earnings,
    this.transactions = const [],
    this.isLoading = false,
    this.isWithdrawing = false,
    this.failure,
  });

  WalletState copyWith({
    WalletEntity? wallet,
    EarningsEntity? earnings,
    List<TransactionEntity>? transactions,
    bool? isLoading,
    bool? isWithdrawing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      earnings: earnings ?? this.earnings,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}