import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/traveler/data/datasource/traveler_remote_data_source.dart';
import '../../features/traveler/data/datasource/traveler_remote_data_source_impl.dart';
import '../../features/traveler/data/repo/traveler_repository_impl.dart';
import '../../features/traveler/domain/repository/traveler_repository.dart';
import '../../features/traveler/domain/usecases/book_trip_usecase.dart';
import '../../features/traveler/domain/usecases/get_destinations_usecase.dart';
import '../../features/traveler/domain/usecases/get_trips_usecase.dart';
import '../../features/traveler/presentation/booking/cubit/booking_cubit.dart';
import '../../features/traveler/presentation/destination/cubit/destinations_cubit.dart';
import '../../features/traveler/presentation/directions/cubit/directions_cubit.dart';
import '../../features/traveler/presentation/trips/cubit/trips_cubit.dart';

import '../../features/driver/data/data source/driver_remote_data_source.dart';
import '../../features/driver/data/repo/driver_repository_impl.dart';
import '../../features/driver/domain/repo interface/driver_repository.dart';
import '../../features/driver/domain/use case/go_offline_use_case.dart';
import '../../features/driver/domain/use case/go_online_use_case.dart';
import '../../features/driver/domain/use case/verify_passenger_use_case.dart';
import '../../features/driver/domain/use case/update_trip_status_use_case.dart';
import '../../features/driver/domain/use case/end_trip_use_case.dart';
import '../../features/driver/presentation/cubit/driver_cubit.dart';

import '../../features/Auth/presentation/cubit/auth_cubit.dart';
import '../../features/Auth/domain/repo interface/auth_repository.dart';
import '../../features/Auth/data/repo/auth_repository_impl.dart';
import '../../features/Auth/domain/usecases/login_usecase.dart';
import '../../features/Auth/domain/usecases/select_role_usecase.dart';
import '../../features/Auth/domain/usecases/rate_trip_usecase.dart';
import '../../features/Auth/domain/repo interface/rating_repository.dart';
import '../../features/Auth/data/repo/rating_repository_impl.dart';

import '../utils/notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firestore
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  // Dio
  sl.registerLazySingleton(() => Dio());

  // Utils
  sl.registerLazySingleton(() => NotificationService());

  // Data Sources
  sl.registerLazySingleton<TravelerRemoteDataSource>(
    () => TravelerRemoteDataSourceImpl(sl<FirebaseFirestore>(), sl<Dio>()),
  );

  sl.registerLazySingleton<DriverRemoteDataSource>(
        () => DriverRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<TravelerRepository>(
    () => TravelerRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<DriverRepository>(
        () => DriverRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(),
  );

  sl.registerLazySingleton<RatingRepository>(
        () => RatingRepositoryImpl(sl()),
  );

  // Traveler Use Cases
  sl.registerLazySingleton(() => GetDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => BookTripUseCase(sl()));

  // Driver Use Cases
  sl.registerLazySingleton(() => GoOnlineUseCase(sl()));
  sl.registerLazySingleton(() => GoOfflineUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPassengerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripStatusUseCase(sl()));
  sl.registerLazySingleton(() => EndTripUseCase(sl()));

  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SelectRoleUseCase(sl()));
  sl.registerLazySingleton(() => RateTripUseCase(sl()));

  // Cubits
  sl.registerFactory(() => DestinationsCubit(sl()));
  sl.registerFactory(() => TripsCubit(sl()));
  sl.registerFactory(() => BookingCubit(sl()));
  sl.registerFactory(() => DirectionsCubit(sl()));
}

  sl.registerFactory(
        () => AuthCubit(
      loginUseCase: sl(),
      selectRoleUseCase: sl(),
      repository: sl<AuthRepositoryImpl>(),
    ),
  );

  sl.registerFactory(
        () => DriverCubit(
      goOnlineUseCase: sl(),
      goOfflineUseCase: sl(),
      verifyPassengerUseCase: sl(),
      updateTripStatusUseCase: sl(),
      endTripUseCase: sl(),
      repository: sl(),
      notificationService: sl(),
    ),
  );
}
