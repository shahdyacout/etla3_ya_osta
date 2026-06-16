import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DriverRemoteDataSource {
  Future<void> updateDriverStatus(String driverId, bool isOnline, {double depositAmount = 0.0});
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDriverStream(String driverId);
  Stream<int> getQueuePositionStream(String driverId);
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveTripStream(String driverId);
  Future<void> verifyPassengerBooking(String bookingId, String driverId);
  Future<void> updateTripStatus(String tripId, String status);
  Future<void> startBoardingWithSeats(String tripId, int availableSeats);
  Future<void> endTrip(String tripId, String driverId, int passengers, double earnings);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final FirebaseFirestore firestore;

  DriverRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> updateDriverStatus(String driverId, bool isOnline, {double depositAmount = 0.0}) async {
    final driverDocRef = firestore.collection('drivers').doc(driverId);

    await firestore.runTransaction((transaction) async {
      final driverSnap = await transaction.get(driverDocRef);
      
      if (isOnline) {
        transaction.set(driverDocRef, {
          'isOnline': true,
          'lastOnlineAt': FieldValue.serverTimestamp(),
          'onlineSince': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        if (driverSnap.exists) {
          final data = driverSnap.data()!;
          final Timestamp? onlineSince = data['onlineSince'] as Timestamp?;
          int totalActiveMinutes = (data['totalActiveMinutes'] as int? ?? 0).clamp(0, 99999);

          if (onlineSince != null) {
            final now = DateTime.now();
            final difference = now.difference(onlineSince.toDate()).inMinutes;
            if (difference > 0) {
              totalActiveMinutes += difference;
            }
          }

          transaction.update(driverDocRef, {
            'isOnline': false,
            'onlineSince': null,
            'totalActiveMinutes': totalActiveMinutes,
          });
        } else {
          transaction.set(driverDocRef, {
            'isOnline': false,
            'onlineSince': null,
            'totalActiveMinutes': 0,
          }, SetOptions(merge: true));
        }
      }
    });

    // Handle Trip Creation separately if Online (to avoid complex transaction dependencies)
    if (isOnline) {
      final tripsQuery = await firestore
          .collection('trips')
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: ['idle', 'boarding', 'inProgress'])
          .limit(1)
          .get();

      if (tripsQuery.docs.isEmpty) {
        final driverDoc = await driverDocRef.get();
        final driverData = driverDoc.data();
        final String destinationId = driverData?['destinationId'] as String? ?? 'unknown';
        final String destinationName = driverData?['destinationName'] as String? ?? 'Unknown';
        final double tripPrice = (driverData?['tripPrice'] as num?)?.toDouble() ?? 0.0;
        const String departurePoint = 'موقف السلام';

        final newTripRef = firestore.collection('trips').doc();
        await newTripRef.set({
          'tripId': newTripRef.id,
          'driverId': driverId,
          'status': 'idle',
          'availableSeats': 14,
          'occupiedSeats': 0,
          'passengers': [],
          'createdAt': FieldValue.serverTimestamp(),
          'route': '$departurePoint → $destinationName',
          'destinationId': destinationId,
          'destinationName': destinationName,
          'departurePoint': departurePoint,
          'price': tripPrice,
          'depositAmount': depositAmount,
        });
      }
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDriverStream(String driverId) {
    return firestore.collection('drivers').doc(driverId).snapshots();
  }

  @override
  Stream<int> getQueuePositionStream(String driverId) {
    return firestore
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .asyncExpand((driverSnap) {
      if (!driverSnap.exists) return Stream.value(0);
      final driverData = driverSnap.data();
      final String? destinationId = driverData?['destinationId'] as String?;
      if (destinationId == null || destinationId.isEmpty) return Stream.value(0);

      return firestore
          .collection('drivers')
          .where('isOnline', isEqualTo: true)
          .where('destinationId', isEqualTo: destinationId)
          .snapshots()
          .map((snapshot) {
        final docs = List<DocumentSnapshot>.from(snapshot.docs);
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>?;
          final bData = b.data() as Map<String, dynamic>?;
          final aTime = aData?['lastOnlineAt'] as Timestamp?;
          final bTime = bData?['lastOnlineAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime);
        });

        for (int i = 0; i < docs.length; i++) {
          if (docs[i].id == driverId) return i + 1;
        }
        return 0;
      });
    });
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveTripStream(String driverId) {
    return firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['idle', 'boarding', 'inProgress'])
        .snapshots();
  }

  @override
  Future<void> verifyPassengerBooking(String bookingId, String driverId) async {
    final tripQuery = await firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'boarding')
        .limit(1)
        .get();

    if (tripQuery.docs.isEmpty) throw Exception('No active boarding session found');
    final tripDoc = tripQuery.docs.first;

    await firestore.runTransaction((transaction) async {
      final tripSnapshot = await transaction.get(tripDoc.reference);
      final tripData = tripSnapshot.data()!;
      final List passengers = List.from(tripData['passengers'] ?? []);
      final int occupied = tripData['occupiedSeats'] ?? 0;

      if (passengers.contains(bookingId)) throw Exception('Passenger already checked in');
      final availableSeats = tripData['availableSeats'] as int? ?? 14;
      if (occupied >= availableSeats) throw Exception('Vehicle is full');

      passengers.add(bookingId);
      transaction.update(tripDoc.reference, {
        'passengers': passengers,
        'occupiedSeats': occupied + 1,
      });
      
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      transaction.set(bookingRef, {'status': 'boarded', 'boardedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    });
  }

  @override
  Future<void> updateTripStatus(String tripId, String status) async {
    await firestore.collection('trips').doc(tripId).update({'status': status});
  }

  @override
  Future<void> startBoardingWithSeats(String tripId, int availableSeats) async {
    await firestore.collection('trips').doc(tripId).update({
      'status': 'boarding',
      'availableSeats': availableSeats,
      'occupiedSeats': 0,
      'passengers': [],
    });
  }

  @override
  Future<void> endTrip(String tripId, String driverId, int passengers, double earnings) async {
    final batch = firestore.batch();
    
    batch.update(firestore.collection('trips').doc(tripId), {'status': 'finished', 'endedAt': FieldValue.serverTimestamp()});
    
    batch.update(firestore.collection('drivers').doc(driverId), {
      'completedTrips': FieldValue.increment(1),
      'totalEarnings': FieldValue.increment(earnings),
      'lastOnlineAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
