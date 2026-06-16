import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use case/get_balance_uc.dart';
import '../../domain/use case/get_earnings_uc.dart';
import '../../domain/use case/get_transactions_uc.dart';
import '../../domain/use case/withdraw_funds_uc.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetBalanceUseCase getBalanceUseCase;
  final GetEarningsUseCase getEarningsUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;
  final WithdrawFundsUseCase withdrawFundsUseCase;

  WalletCubit({
    required this.getBalanceUseCase,
    required this.getEarningsUseCase,
    required this.getTransactionsUseCase,
    required this.withdrawFundsUseCase,
  }) : super(const WalletState());

  /// Get wallet balance
  Future<void> getBalance() async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getBalanceUseCase();
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )),
      (wallet) => emit(state.copyWith(
        isLoading: false,
        wallet: wallet,
        clearFailure: true,
      )),
    );
  }

  /// Get earnings data
  Future<void> getEarnings() async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getEarningsUseCase();
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )),
      (earnings) => emit(state.copyWith(
        isLoading: false,
        earnings: earnings,
        clearFailure: true,
      )),
    );
  }

  /// Get transactions list
  Future<void> getTransactions() async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getTransactionsUseCase();
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )),
      (transactions) => emit(state.copyWith(
        isLoading: false,
        transactions: transactions,
        clearFailure: true,
      )),
    );
  }

  /// Withdraw funds from wallet
  Future<void> withdrawFunds(double amount) async {
    emit(state.copyWith(isWithdrawing: true));
    
    final result = await withdrawFundsUseCase(amount);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isWithdrawing: false,
        failure: failure,
      )),
      (_) => emit(state.copyWith(
        isWithdrawing: false,
        clearFailure: true,
      )),
    );
  }

  /// Clear failure message
  void clearFailure() {
    emit(state.copyWith(clearFailure: true));
  }

  /// Reset wallet state
  void reset() {
    emit(const WalletState());
  }
}

