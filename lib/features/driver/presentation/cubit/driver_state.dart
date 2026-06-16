import 'package:etla3_ya_osta/core/error/failures.dart';

enum DriverTripStatus { idle, boarding, inProgress, finished }

class DriverState {
  final bool isLoading;
  final bool isOnline;
  final int queuePosition;
  final int completedTrips;
  final double totalEarnings;
  final double activeHours;
  final double avgRating;
  final String? activeTripId;
  final int availableSeats;
  final int occupiedSeats;
  final Failure? failure;
  final bool isVerifying;
  final String? verificationMessage;
  final bool? verificationSuccess;
  
  // New workflow states
  final DriverTripStatus tripStatus;
  final List<String> checkedInPassengerIds;
  final DateTime? tripStartTime;

  const DriverState({
    this.isLoading = false,
    this.isOnline = false,
    this.queuePosition = 0,
    this.completedTrips = 0,
    this.totalEarnings = 0.0,
    this.activeHours = 0.0,
    this.avgRating = 0.0,
    this.activeTripId,
    this.availableSeats = 14,
    this.occupiedSeats = 0,
    this.failure,
    this.isVerifying = false,
    this.verificationMessage,
    this.verificationSuccess,
    this.tripStatus = DriverTripStatus.idle,
    this.checkedInPassengerIds = const [],
    this.tripStartTime,
  });

  DriverState copyWith({
    bool? isLoading,
    bool? isOnline,
    int? queuePosition,
    int? completedTrips,
    double? totalEarnings,
    double? activeHours,
    double? avgRating,
    String? activeTripId,
    int? availableSeats,
    int? occupiedSeats,
    Failure? failure,
    bool? isVerifying,
    String? verificationMessage,
    bool? verificationSuccess,
    DriverTripStatus? tripStatus,
    List<String>? checkedInPassengerIds,
    DateTime? tripStartTime,
    bool clearVerification = false,
    bool clearFailure = false,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      queuePosition: queuePosition ?? this.queuePosition,
      completedTrips: completedTrips ?? this.completedTrips,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      activeHours: activeHours ?? this.activeHours,
      avgRating: avgRating ?? this.avgRating,
      activeTripId: activeTripId ?? this.activeTripId,
      availableSeats: availableSeats ?? this.availableSeats,
      occupiedSeats: occupiedSeats ?? this.occupiedSeats,
      failure: clearFailure ? null : failure ?? this.failure,
      isVerifying: isVerifying ?? this.isVerifying,
      verificationMessage: clearVerification ? null : verificationMessage ?? this.verificationMessage,
      verificationSuccess: clearVerification ? null : verificationSuccess ?? this.verificationSuccess,
      tripStatus: tripStatus ?? this.tripStatus,
      checkedInPassengerIds: checkedInPassengerIds ?? this.checkedInPassengerIds,
      tripStartTime: tripStartTime ?? this.tripStartTime,
    );
  }
}
