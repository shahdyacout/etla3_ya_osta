import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:etla3_ya_osta/core/error/failures.dart';

abstract class DriverRepository {
  Future<Either<Failure, void>> goOnline(String driverId, {double depositAmount = 0.0});
  Future<Either<Failure, void>> goOffline(String driverId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDriverStream(String driverId);
  Stream<int> getQueuePositionStream(String driverId);
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveTripStream(String driverId);
  Future<Either<Failure, void>> verifyPassengerBooking(String bookingId, String driverId);
  Future<Either<Failure, void>> updateTripStatus(String tripId, String status);
  Future<Either<Failure, void>> startBoardingWithSeats(String tripId, int availableSeats);
  Future<Either<Failure, void>> endTrip(String tripId, String driverId, int passengers, double earnings);
}
