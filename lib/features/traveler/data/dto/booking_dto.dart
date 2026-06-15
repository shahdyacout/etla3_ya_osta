import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etla3_ya_osta/core/entities/booking_entity.dart';

class BookingDto extends BookingEntity {


  BookingDto({
    required super.bookingId,
    required super.tripId,
    required super.travelerId,
    required super.status,
    required super.seatNumber,
    required super.createdAt,

  });

  factory BookingDto.fromJson(String id, Map<String, dynamic> json) {
    return BookingDto(
      bookingId: json['bookingId'] ?? id,
      tripId: json['tripId'] ?? '',
      travelerId: json['travelerId'] ?? '',
      seatNumber: json['seatNumber'] ?? 0,
      status: json['status'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'tripId': tripId,
      'travelerId': travelerId,
      'seatNumber': seatNumber,
      'status': status,
    };
  }
}
