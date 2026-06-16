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
import '../../features/payment/di/payment_injection.dart';
import '../../features/notifications/data/data_source/notifications_firestore_ds.dart';
import '../../features/notifications/data/repo/notifications_repo_impl.dart';
import '../../features/notifications/domain/repo/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_read_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton(() => FirebaseAuth.instance);
  }

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

  // Payment
  setupPaymentInjection(sl);

  // Notifications Data Source
  sl.registerLazySingleton(
    () => NotificationsFirestoreDataSource(firestore: sl(), auth: sl()),
  );

  // Notifications Repository
  sl.registerLazySingleton<INotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );

  // Notifications Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));

  // Notifications Cubit
  sl.registerFactory(
    () => NotificationsCubit(
      getNotifications: sl(),
      markAsRead: sl(),
      markAllRead: sl(),
    ),
  );
}