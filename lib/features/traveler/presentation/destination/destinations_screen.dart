import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'cubit/destinations_cubit.dart';
import 'cubit/destinations_state.dart';


class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final cubit = context.read<DestinationsCubit>();

    if (cubit.state is DestinationsInitial) {
      cubit.loadDestinations();
    }
  }
  @override
  Widget build(BuildContext context) {
    // الألوان المستوحاة من التصميم

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color:AppColors.textDark),
        title: const Text(
          "Masar",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textDark),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // جزء المحطة الحالية والـ Map View
          Container(
            width: double.infinity,
            color: const Color(0xFFE5E9E8),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // زرار المحطة الحالية
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation_outlined, color:  AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text("Cairo Central Station", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // أيقونة الخريطة
                const Icon(Icons.location_on, color:  AppColors.primary, size: 50),
                const SizedBox(height: 4),
                const Text("Map View", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // جزء البحث والـ Destinations
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Where are you going?", style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // حقل البحث
                  TextField(
                    onChanged: (value) => context.read<DestinationsCubit>().searchDestinations(value),
                    cursorColor:  AppColors.primary,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: "Search destination...",
                      hintStyle: TextStyle(color: AppColors.grey),
                      prefixIcon: Icon(Icons.search, color: AppColors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Popular Destinations", style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // لستة الوجهات المربوطة بالـ Cubit
                  Expanded(
                    child: BlocBuilder<DestinationsCubit, DestinationsState>(
                      builder: (context, state) {
                        if (state is DestinationsLoading) {
                          return const Center(child: CircularProgressIndicator(color:  AppColors.primary));
                        }
                        if (state is DestinationsError) {
                          return Center(child: Text("Error: ${state.message}"));
                        }
                        if (state is DestinationsLoaded) {
                          return ListView.builder(
                            itemCount: state.destinations.length,
                            itemBuilder: (context, index) {
                              final item = state.destinations[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.lightGrey),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(item.nameEn, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                                  // بيانات تجريبية للمسافة والوقت كما في الموك سكرين
                                 // subtitle: const Text("220 km • 3h 30m", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey, size: 16),onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.trips,
                                      arguments: item.id,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text("No Data"));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}