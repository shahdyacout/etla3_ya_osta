class BookingEntity {
  final String bookingId;
  final String tripId;
  final String travelerId;
  final int seatNumber;

  BookingEntity({
    required this.bookingId,
    required this.tripId,
    required this.travelerId,
    required this.seatNumber,
  });
}