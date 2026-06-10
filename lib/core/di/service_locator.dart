import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../features/traveler/presentation/trips/cubit/trips_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Firestore
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // DataSource
  sl.registerLazySingleton<TravelerRemoteDataSource>(
        () => TravelerRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TravelerRepository>(
        () => TravelerRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => BookTripUseCase(sl()));

  // Cubits (NEW ARCH)
  sl.registerFactory(() => DestinationsCubit(sl()));
  sl.registerFactory(() => TripsCubit(sl()));
  sl.registerFactory(() => BookingCubit(sl()));
}