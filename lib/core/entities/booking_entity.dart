class BookingEntity {
  final String bookingId;
  final String tripId;
  final String travelerId;
  final int seatNumber;
  final String status;
  final DateTime createdAt;
  final String driverId;


  BookingEntity({
    required this.bookingId,
    required this.tripId,
    required this.travelerId,
    required this.seatNumber,
    required this.status,
    required this.createdAt,
    required this.driverId,
  });
}