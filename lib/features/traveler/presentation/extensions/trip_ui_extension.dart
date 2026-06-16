import '../../../../core/entities/trip_entity.dart';

extension TripUI on TripEntity {
  String get priceText => "$price EGP";

  String get seatsText => "$availableSeats seats left";

  String get departureText => "Departure: $departurePoint";

  String get ratingText => driverRating > 0 ? driverRating.toStringAsFixed(1) : "New";

  bool get isActive => status == "boarding";
}