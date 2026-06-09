
class TripEntity {
  final String tripId;
  final String driverId;
  final String destinationId;
  final String destinationName;
  final String departurePoint;
  final String status;
  final double price;
  final int availableSeats;
  final int occupiedSeats;

  TripEntity({
    required this.tripId,
    required this.driverId,
    required this.destinationId,
    required this.destinationName,
    required this.departurePoint,
    required this.status,
    required this.price,
    required this.availableSeats,
    required this.occupiedSeats,
  });
}