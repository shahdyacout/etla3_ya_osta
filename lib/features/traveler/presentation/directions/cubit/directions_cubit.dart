import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repository/traveler_repository.dart';
import 'directions_state.dart';

class DirectionsCubit extends Cubit<DirectionsState> {
  final TravelerRepository repository;

  DirectionsCubit(this.repository) : super(DirectionsInitial());

  // جلب البيانات أول مرة
  void loadDirections() async {
    emit(DirectionsLoading());
    try {
      final steps = await repository.getLiveDirections();
      emit(DirectionsLoaded(steps));
    } catch (e) {
      emit(DirectionsError("فشل في تحميل التوجيهات"));
    }
  }

  // ميثود هيستدعيها الـ FCM لما الأوتوبيس يغير الـ Bay بتاعه فجأة
  void updateBusBayFromFCM(String newBayText) {
    if (state is DirectionsLoaded) {
      final currentSteps = (state as DirectionsLoaded).steps;

      // تحديث الخطوة الأخيرة الخاصة بالأوتوبيس
      final updatedSteps = currentSteps.map((step) {
        if (step.text.contains("Bus ABC")) {
          return step.copyWith(status: step.status); // تقدري تغيري النص هنا
        }
        return step;
      }).toList();

      emit(DirectionsLoaded(updatedSteps));
    }
  }
}