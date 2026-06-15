import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../dto/DirectionStepDto.dart';
import '../dto/booking_dto.dart';
import '../dto/destination_dto.dart';
import '../dto/trip_dto.dart';
import 'traveler_remote_data_source.dart';

class TravelerRemoteDataSourceImpl implements TravelerRemoteDataSource {
  final FirebaseFirestore firestore;
  final Dio _dio;
  final String _apiKey = "AIzaSyDETFJrKjHXUFkELhZD1mcQclr2WLctCto";

  TravelerRemoteDataSourceImpl(this.firestore, this._dio);

  @override
  Future<List<DestinationDto>> getDestinations() async {
    final res = await firestore.collection('destinations').get();

    return res.docs
        .map((e) => DestinationDto.fromJson(e.id, e.data()))
        .toList();
  }

  @override
  Future<List<TripDto>> getTrips(String destinationId) async {
    final res = await firestore
        .collection('trips')
        .where('destinationId', isEqualTo: destinationId)
        .get();

    return res.docs.map((e) => TripDto.fromJson(e.id, e.data())).toList();
  }

  @override
  Future<BookingDto> bookTrip({
    required String tripId,
    required String travelerId,
    required int seatNumber,
  }) async {
    final bookingRef = firestore.collection('bookings').doc();

    await firestore.runTransaction((transaction) async {
      final tripRef = firestore.collection('trips').doc(tripId);

      final tripSnapshot = await transaction.get(tripRef);

      final availableSeats = tripSnapshot['availableSeats'];

      if (seatNumber > availableSeats) {
        throw Exception('Only $availableSeats seats available');
      }

      transaction.update(tripRef, {
        'availableSeats': availableSeats - seatNumber,
        'occupiedSeats': tripSnapshot['occupiedSeats'] + seatNumber,
      });

      transaction.set(bookingRef, {
        'bookingId': bookingRef.id,
        'tripId': tripId,
        'travelerId': travelerId,
        'seatNumber': seatNumber,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return BookingDto(
      bookingId: bookingRef.id,
      tripId: tripId,
      travelerId: travelerId,
      seatNumber: seatNumber,
      status: "confirmed",
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    final doc = await firestore.collection('bookings').doc(bookingId).get();

    if (!doc.exists) {
      throw Exception('Booking not found');
    }

    return BookingDto.fromJson(doc.id, doc.data()!);
  }
  //
  // @override
  // Future<List<DirectionStepDto>> getLiveDirections() async {
  //   try {
  //     // إحداثيات افتراضية كمثال (تقدري تغيريها بموقع المستخدم الحقيقي لاحقاً)
  //     final String origin = "30.0444,31.2357"; // رمسيس / محطة مصر
  //     final String destination = "30.0511,31.2415"; // نقطة قريبة كمثال
  //
  //     final response = await _dio.get(
  //       'https://maps.googleapis.com/maps/api/directions/json',
  //       queryParameters: {
  //         'origin': origin,
  //         'destination': destination,
  //         'mode': 'walking',
  //         'key': _apiKey,
  //         'language': 'en',
  //       },
  //     );
  //     print("Directions Response: ${response.data}");
  //
  //     if (response.statusCode == 200 && response.data['status'] == 'OK') {
  //       final List<DirectionStepDto> extractedSteps = [];
  //
  //       final route = response.data['routes'][0];
  //       final legs = route['legs'][0];
  //       final googleSteps = legs['steps'] as List;
  //
  //       for (int i = 0; i < googleSteps.length; i++) {
  //         final stepData = googleSteps[i];
  //
  //         // تنظيف النص لأن جوجل بترجع النصوص جواه تاجات HTML زي <b>
  //         String rawText = stepData['html_instructions'] ?? "";
  //         String cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '');
  //
  //         extractedSteps.add(
  //           DirectionStepDto(
  //             text: cleanText,
  //             distance: stepData['distance']['text'] ?? "0m",
  //             // بنخلي أول خطوة هي الـ current والباقي pending كبداية
  //             status: i == 0 ? 'current' : 'pending',
  //           ),
  //         );
  //       }
  //
  //       return extractedSteps;
  //     } else {
  //       throw Exception("جوجل ماب رجعت خطأ: ${response.data['status']}");
  //     }
  //   } catch (e) {
  //     throw Exception("فشل الاتصال بالـ API: $e");
  //   }
  // }
  @override
  Future<List<DirectionStepDto>> getLiveDirections() async {
    // محاكاة لجلب البيانات من الـ API (Mock Data) لشاشتك
    await Future.delayed(const Duration(seconds: 1)); // تأخير وهمي للشبكة
    return [
      DirectionStepDto(text: "Enter Cairo Central Station", distance: "0m", status: "done"),
      DirectionStepDto(text: "Head to Platform B", distance: "50m", status: "current"),
      DirectionStepDto(text: "Walk 50 meters straight", distance: "50m", status: "pending"),
      DirectionStepDto(text: "Bus ABC 1234 at Bay 7", distance: "150m", status: "pending"),
    ];
  }
}
