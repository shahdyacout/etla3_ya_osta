import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../features/wallet/data/data source/wallet_firestore_ds.dart';
import '../../features/wallet/data/repo/wallet_repo_impl.dart';
import '../../features/wallet/domain/repo interface/i_wallet_repository.dart';
import '../../features/wallet/domain/use case/get_balance_uc.dart';
import '../../features/wallet/domain/use case/get_earnings_uc.dart';
import '../../features/wallet/domain/use case/get_transactions_uc.dart';
import '../../features/wallet/domain/use case/withdraw_funds_uc.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Wallet Data Source
  sl.registerLazySingleton(
        () => WalletFirestoreDataSource(
      firestore: sl(),
      auth: sl(),
    ),
  );

  // Wallet Repository
  sl.registerLazySingleton<IWalletRepository>(
        () => WalletRepositoryImpl(sl()),
  );

  // Wallet Use Cases
  sl.registerLazySingleton(() => GetBalanceUseCase(sl()));
  sl.registerLazySingleton(() => GetEarningsUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => WithdrawFundsUseCase(sl()));

  // Wallet Cubit
  sl.registerFactory(
        () => WalletCubit(
      getBalanceUseCase:      sl(),
      getEarningsUseCase:     sl(),
      getTransactionsUseCase: sl(),
      withdrawFundsUseCase:   sl(),
    ),
  );
}
