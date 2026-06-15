import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etla3_ya_osta/core/error/failures.dart';
import 'package:etla3_ya_osta/features/driver/domain/repo interface/driver_repository.dart';
import 'package:etla3_ya_osta/features/driver/domain/use case/go_online_use_case.dart';
import 'package:etla3_ya_osta/features/driver/domain/use case/go_offline_use_case.dart';
import 'package:etla3_ya_osta/features/driver/domain/use case/verify_passenger_use_case.dart';
import 'package:etla3_ya_osta/features/driver/domain/use case/update_trip_status_use_case.dart';
import 'package:etla3_ya_osta/features/driver/domain/use case/end_trip_use_case.dart';
import '../../../../core/utils/notification_service.dart';
import 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final GoOnlineUseCase goOnlineUseCase;
  final GoOfflineUseCase goOfflineUseCase;
  final VerifyPassengerUseCase verifyPassengerUseCase;
  final UpdateTripStatusUseCase updateTripStatusUseCase;
  final EndTripUseCase endTripUseCase;
  final DriverRepository repository;
  final NotificationService notificationService;

  StreamSubscription? _driverSubscription;
  StreamSubscription? _queueSubscription;
  StreamSubscription? _activeTripSubscription;

  String? _driverId;

  DriverCubit({
    required this.goOnlineUseCase,
    required this.goOfflineUseCase,
    required this.verifyPassengerUseCase,
    required this.updateTripStatusUseCase,
    required this.endTripUseCase,
    required this.repository,
    required this.notificationService,
  }) : super(const DriverState());

  void initDriver(String driverId) {
    if (_driverId == driverId) return;
    _driverId = driverId;
    _cancelSubscriptions();

    emit(state.copyWith(isLoading: true));
    
    // Initialize notifications and save token
    notificationService.initialize();
    notificationService.saveToken(driverId);

    _driverSubscription = repository.getDriverStream(driverId).listen(
      (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final isOnline = data['isOnline'] as bool? ?? false;
          final completedTrips = data['completedTrips'] as int? ?? 0;
          final totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          
          // Calculate Active Hours from totalActiveMinutes
          final totalMinutes = data['totalActiveMinutes'] as int? ?? 0;
          final activeHours = totalMinutes / 60.0;
          
          final avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0.0;

          emit(state.copyWith(
            isLoading: false,
            isOnline: isOnline,
            completedTrips: completedTrips,
            totalEarnings: totalEarnings,
            activeHours: activeHours,
            avgRating: avgRating,
          ));

          if (isOnline) {
            _startOnlineSubscriptions(driverId);
          } else {
            _stopOnlineSubscriptions();
          }
        } else {
          repository.goOffline(driverId);
          emit(state.copyWith(isLoading: false, isOnline: false));
        }
      },
      onError: (error) {
        emit(state.copyWith(isLoading: false, failure: ServerFailure(error.toString())));
      },
    );
  }

  void _startOnlineSubscriptions(String driverId) {
    _queueSubscription?.cancel();
    _queueSubscription = repository.getQueuePositionStream(driverId).listen(
      (pos) {
        emit(state.copyWith(queuePosition: pos));
      },
    );

    _activeTripSubscription?.cancel();
    _activeTripSubscription = repository.getActiveTripStream(driverId).listen(
      (snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final tripDoc = snapshot.docs.first;
          final tripData = tripDoc.data();
          final available = tripData['availableSeats'] as int? ?? 14;
          final occupied = tripData['occupiedSeats'] as int? ?? 0;
          final passengers = List<String>.from(tripData['passengers'] ?? []);
          final statusStr = tripData['status'] as String? ?? 'idle';
          
          DriverTripStatus status = DriverTripStatus.idle;
          if (statusStr == 'boarding') status = DriverTripStatus.boarding;
          if (statusStr == 'inProgress') status = DriverTripStatus.inProgress;
          if (statusStr == 'finished') status = DriverTripStatus.finished;

          emit(state.copyWith(
            activeTripId: tripDoc.id,
            availableSeats: available,
            occupiedSeats: occupied,
            checkedInPassengerIds: passengers,
            tripStatus: status,
          ));
        } else {
          emit(state.copyWith(
            activeTripId: null,
            availableSeats: 14,
            occupiedSeats: 0,
            checkedInPassengerIds: [],
            tripStatus: DriverTripStatus.idle,
          ));
        }
      },
    );
  }

  void _stopOnlineSubscriptions() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
    _activeTripSubscription?.cancel();
    _activeTripSubscription = null;
    emit(state.copyWith(
      queuePosition: 0,
      activeTripId: null,
      availableSeats: 14,
      occupiedSeats: 0,
      checkedInPassengerIds: [],
      tripStatus: DriverTripStatus.idle,
    ));
  }

  Future<void> goOnline() async {
    if (_driverId == null) return;
    emit(state.copyWith(isLoading: true));
    final result = await goOnlineUseCase(_driverId!);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) {},
    );
  }

  Future<void> goOffline() async {
    if (_driverId == null) return;
    emit(state.copyWith(isLoading: true));
    final result = await goOfflineUseCase(_driverId!);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) {},
    );
  }

  Future<void> startBoarding() async {
    if (state.activeTripId == null) return;
    emit(state.copyWith(isLoading: true));
    final result = await updateTripStatusUseCase(state.activeTripId!, 'boarding');
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> startTrip() async {
    if (state.activeTripId == null) return;
    emit(state.copyWith(isLoading: true));
    final result = await updateTripStatusUseCase(state.activeTripId!, 'inProgress');
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(state.copyWith(isLoading: false, tripStartTime: DateTime.now())),
    );
  }

  Future<void> endTrip() async {
    if (state.activeTripId == null || _driverId == null) return;
    emit(state.copyWith(isLoading: true));
    final earnings = state.occupiedSeats * 50.0;
    final result = await endTripUseCase(state.activeTripId!, _driverId!, state.occupiedSeats, earnings);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  void resetToHome() {
    emit(state.copyWith(
      tripStatus: DriverTripStatus.idle,
      activeTripId: null,
      occupiedSeats: 0,
      checkedInPassengerIds: [],
    ));
  }

  Future<void> verifyPassenger(String bookingId) async {
    if (_driverId == null) return;
    
    emit(state.copyWith(isVerifying: true, clearVerification: true));
    final result = await verifyPassengerUseCase(bookingId, _driverId!);
    result.fold(
      (failure) => emit(state.copyWith(
        isVerifying: false,
        verificationSuccess: false,
        verificationMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isVerifying: false,
        verificationSuccess: true,
        verificationMessage: 'Passenger checked in successfully!',
      )),
    );
  }

  void clearVerificationState() {
    emit(state.copyWith(clearVerification: true));
  }

  void _cancelSubscriptions() {
    _driverSubscription?.cancel();
    _driverSubscription = null;
    _stopOnlineSubscriptions();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
