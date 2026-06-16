import 'package:etla3_ya_osta/features/traveler/presentation/directions/view/stepper_item.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';



import '../../../../../core/theme/app_colors.dart';

import '../cubit/directions_cubit.dart';

import '../cubit/directions_state.dart';



class LiveDirectionsScreen extends StatelessWidget {

  const LiveDirectionsScreen({super.key});



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color:AppColors.primary), // Replaced AppColors.primary with your hex if not imported

          onPressed: () => Navigator.pop(context),

        ),

        title: const Text(

          "Live Directions",

          style: TextStyle(

            color: AppColors.primary, // Replaced AppColors.primary

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: SafeArea(

        child: BlocProvider<DirectionsCubit>(

          create: (_) => sl<DirectionsCubit>()..loadDirections(),

          child: BlocBuilder<DirectionsCubit, DirectionsState>(

            builder: (context, state) {

              if (state is DirectionsLoading) {

                return const Center(

                    child: CircularProgressIndicator(color: Color(0xFF84A59D)));

              } else if (state is DirectionsLoaded) {

                return SingleChildScrollView( // Added scroll view for safety

                  padding: const EdgeInsets.all(16.0),

                  child: Column(

                    children: [

                      // تقدري هنا تحطي كارت الـ 150m العلوي لاحقاً

                      const SizedBox(height: 8),



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

                            ]),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          mainAxisSize: MainAxisSize.min,

                          children: [

                            // لستة التوجيهات

                            ListView.builder(

                              shrinkWrap: true,

                              physics: const NeverScrollableScrollPhysics(),

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