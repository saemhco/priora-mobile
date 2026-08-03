import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/presentation/doctor_agenda_screen.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/data/doctor_appointments_service.dart';
import 'package:priora/features/doctor/appointments/presentation/doctor_appointments_screen.dart';
import 'package:priora/features/doctor/navigation/controller/doctor_navigation_controller.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/doctor_places_screen.dart';
import 'package:priora/features/doctor/profile/presentation/doctor_profile_screen.dart';
import 'package:priora/features/patient/navigation/presentation/widgets/patient_nav_item.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class DoctorNavigationScreen extends StatefulWidget {
  const DoctorNavigationScreen({super.key});

  @override
  State<DoctorNavigationScreen> createState() =>
      _DoctorNavigationScreenState();
}

class _DoctorNavigationScreenState extends State<DoctorNavigationScreen> {
  late final DoctorAppointmentsCubit _appointmentsCubit;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    final authState = getIt<AuthBloc>().state;
    _appointmentsCubit = DoctorAppointmentsCubit(
      getIt<DoctorAppointmentsService>(),
      authState is AuthAuthenticated ? authState.accessToken : '',
    );
    _tabs = [
      const DoctorAgendaScreen(),
      const DoctorAppointmentsScreen(),
      const DoctorPlacesScreen(),
      const DoctorProfileScreen(),
    ];
    _appointmentsCubit.loadAppointments();
  }

  @override
  void dispose() {
    _appointmentsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlacesCubit>.value(
      value: getIt<PlacesCubit>(),
      child: BlocProvider<DoctorAppointmentsCubit>.value(
        value: _appointmentsCubit,
        child: BlocProvider<DoctorNavigationCubit>(
          create: (context) => DoctorNavigationCubit(),
          child: BlocBuilder<DoctorNavigationCubit, int>(
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
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                Icons.calendar_month_outlined,
                'Mi Agenda',
              ),
              _buildNavItem(
                context,
                currentIndex,
                1,
                Icons.event_outlined,
                'Citas',
              ),
              _buildNavItem(
                context,
                currentIndex,
                2,
                Icons.place_outlined,
                'Lugares',
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
      onTap: () => context.read<DoctorNavigationCubit>().changeIndex(index),
    );
  }
}
