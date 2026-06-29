import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/appointments/presentation/appointments_screen.dart';
import 'package:priora/features/patient/home/presentation/patient_home_screen.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/navigation/presentation/widgets/patient_nav_item.dart';
import 'package:priora/features/patient/profile/presentation/patient_profile_screen.dart';
import 'package:priora/features/patient/triage/presentation/health_screen.dart';

class PatientNavigationScreen extends StatefulWidget {
  const PatientNavigationScreen({super.key});

  @override
  State<PatientNavigationScreen> createState() =>
      _PatientNavigationScreenState();
}

class _PatientNavigationScreenState extends State<PatientNavigationScreen> {
  final List<Widget> _tabs = [
    const PatientHomeScreen(),
    const HealthScreen(),
    const PatientAppointmentsScreen(),
    const PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PatientNavigationCubit>(
      create: (context) => PatientNavigationCubit(),
      child: BlocBuilder<PatientNavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: currentIndex,
                children: _tabs,
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(
              context,
              currentIndex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                currentIndex,
                0,
                Icons.home_rounded,
                'Inicio',
              ),
              _buildNavItem(
                context,
                currentIndex,
                1,
                Icons.favorite_border_rounded,
                'Salud',
              ),
              _buildNavItem(
                context,
                currentIndex,
                2,
                Icons.calendar_today_outlined,
                'Mis citas',
              ),
              _buildNavItem(
                context,
                currentIndex,
                3,
                Icons.person_outline_rounded,
                'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int currentIndex,
    int index,
    IconData icon,
    String label,
  ) {
    return PatientNavItem(
      index: index,
      icon: icon,
      label: label,
      isSelected: currentIndex == index,
      onTap: () => context.read<PatientNavigationCubit>().changeIndex(index),
    );
  }
}
