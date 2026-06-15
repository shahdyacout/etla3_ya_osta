import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/data/data source/driver_remote_data_source.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;

  DriverRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> goOnline(String driverId) async {
    try {
      await remoteDataSource.updateDriverStatus(driverId, true);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> goOffline(String driverId) async {
    try {
      await remoteDataSource.updateDriverStatus(driverId, false);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDriverStream(String driverId) {
    return remoteDataSource.getDriverStream(driverId);
  }

  @override
  Stream<int> getQueuePositionStream(String driverId) {
    return remoteDataSource.getQueuePositionStream(driverId);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveTripStream(String driverId) {
    return remoteDataSource.getActiveTripStream(driverId);
  }

  @override
  Future<Either<Failure, void>> verifyPassengerBooking(String bookingId, String driverId) async {
    try {
      await remoteDataSource.verifyPassengerBooking(bookingId, driverId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> updateTripStatus(String tripId, String status) async {
    try {
      await remoteDataSource.updateTripStatus(tripId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endTrip(String tripId, String driverId, int passengers, double earnings) async {
    try {
      await remoteDataSource.endTrip(tripId, driverId, passengers, earnings);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
