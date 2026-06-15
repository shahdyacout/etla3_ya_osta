import 'package:etla3_ya_osta/features/traveler/presentation/directions/view/stepper_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service_locator.dart';
import '../cubit/directions_cubit.dart';
import '../cubit/directions_state.dart';

class LiveDirectionsScreen extends StatelessWidget {
  const LiveDirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية الشاشة الخارجية رمادي فاتح جداً
      body: SafeArea(
        child: BlocProvider(
          create: (_) => sl<DirectionsCubit>()..loadDirections(),
          child: BlocBuilder<DirectionsCubit, DirectionsState>(
            builder: (context, state) {
              if (state is DirectionsLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF84A59D)));
              } else if (state is DirectionsLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // تقدري هنا تحطي كارت الـ 150m العلوي لاحقاً
                      const SizedBox(height: 20),

                      // الـ Container الأبيض الكبير المحيط بالـ Live Directions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // كلمة Live Directions العلوية
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0, bottom: 12, top: 4),
                              child: Text(
                                "Live Directions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF52796F), // الدرجة الزيتية المكتوب بيها الهيدر
                                ),
                              ),
                            ),
                            // لستة التوجيهات
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(), // لأنها جوة Column
                              itemCount: state.steps.length,
                              itemBuilder: (context, index) {
                                return StepperItem(step: state.steps[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is DirectionsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}