import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repository/traveler_repository.dart';
import 'directions_state.dart';

class DirectionsCubit extends Cubit<DirectionsState> {
  final TravelerRepository repository;
  Timer? _mockTimer;

  DirectionsCubit(this.repository) : super(DirectionsInitial());

  // جلب البيانات أول مرة وابدأ الـ Mocking
  void loadDirections() async {
    emit(DirectionsLoading());
    try {
      final steps = await repository.getLiveDirections();
      emit(DirectionsLoaded(steps));
      
      // ابدأ عملية المحاكاة (Mocking) بعد تحميل البيانات
      startMockingProgression();
    } catch (e) {
      emit(DirectionsError("فشل في تحميل التوجيهات"));
    }
  }

  void startMockingProgression() {
    _mockTimer?.cancel();
    int currentIndex = 0;

    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state is DirectionsLoaded) {
        final currentSteps = (state as DirectionsLoaded).steps;
        
        if (currentIndex < currentSteps.length) {
          final updatedSteps = List.of(currentSteps);
          
          // تحويل الخطوة الحالية لـ 'done'
          updatedSteps[currentIndex] = updatedSteps[currentIndex].copyWith(status: 'done');
          
          // تحويل الخطوة التالية لـ 'current' لو موجودة
          if (currentIndex + 1 < updatedSteps.length) {
            updatedSteps[currentIndex + 1] = updatedSteps[currentIndex + 1].copyWith(status: 'current');
          }
          
          emit(DirectionsLoaded(updatedSteps));
          currentIndex++;
        } else {
          timer.cancel();
        }
      }
    });
  }

  // ميثود هيستدعيها الـ FCM لما الأوتوبيس يغير الـ Bay بتاعه فجأة
  void updateBusBayFromFCM(String newBayText) {
    if (state is DirectionsLoaded) {
      final currentSteps = (state as DirectionsLoaded).steps;

      final updatedSteps = currentSteps.map((step) {
        if (step.text.contains("Bus ABC")) {
          return step.copyWith(status: step.status); 
        }
        return step;
      }).toList();

      emit(DirectionsLoaded(updatedSteps));
    }
  }

  @override
  Future<void> close() {
    _mockTimer?.cancel();
    return super.close();
  }
}
