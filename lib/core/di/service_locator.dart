import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../features/traveler/data/data source/traveler_remote_data_source.dart';
import '../../features/traveler/data/data source/traveler_remote_data_source_impl.dart';
import '../../features/traveler/data/repo/traveler_repository_impl.dart';
import '../../features/traveler/domain/repo interface/traveler_repository.dart';
import '../../features/traveler/domain/usecase/book_trip_usecase.dart';
import '../../features/traveler/domain/usecase/get_destinations_usecase.dart';
import '../../features/traveler/domain/usecase/get_trips_usecase.dart';
import '../../features/traveler/presentation/cubit/traveler_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // Firestore
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // DataSource
  sl.registerLazySingleton<TravelerRemoteDataSource>(
        () => TravelerRemoteDataSourceImpl(sl()),
  );

  // Repo
  sl.registerLazySingleton<TravelerRepository>(
        () => TravelerRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => BookTripUseCase(sl()));

  // Cubit
  sl.registerFactory(
        () => TravelerCubit(sl(), sl(), sl()),
  );
}