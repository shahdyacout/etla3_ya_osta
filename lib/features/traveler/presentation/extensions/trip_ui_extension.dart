
import '../../../../core/entities/trip_entity.dart';

extension TripUI on TripEntity {
  String get priceText => "$price EGP";

  String get seatsText => "$availableSeats seats left";

  String get departureText => "Departure: $departurePoint";

  bool get isActive => status == "active" || status == "available";
}