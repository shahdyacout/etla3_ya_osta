import 'package:get_it/get_it.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/use_case/create_payment_intent_usecase.dart';
import '../presentation/cubit/payment_cubit.dart';

void setupPaymentInjection(GetIt sl) {
  // Repository
  sl.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(),
  );

  // Use Case
  sl.registerLazySingleton(
        () => CreatePaymentIntentUseCase(sl()),
  );

  // Cubit
  sl.registerFactory(
        () => PaymentCubit(sl()),
  );
}