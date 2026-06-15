
import '../../../../core/entities/trip_entity.dart';

class TripDto extends TripEntity {
  TripDto({
    required super.tripId,
    required super.driverId,
    required super.destinationId,
    required super.destinationName,
    required super.price,
    required super.availableSeats,
    required super.occupiedSeats,
    required super.departurePoint,
    required super.status,
  });

  factory TripDto.fromJson(String id, Map<String, dynamic> json) {
    return TripDto(
      tripId: id,
      driverId: json['driverId'],
      destinationId: json['destinationId'],
      destinationName: json['destinationName'],
      price: json['price'],
      availableSeats: json['availableSeats'],
      occupiedSeats: json['occupiedSeats'],
      departurePoint: json['departurePoint'],
      status: json['status'],
    );
  }
}