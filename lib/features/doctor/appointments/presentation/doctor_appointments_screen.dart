import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_error.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_list.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_loading.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_tabs.dart';

/// Doctor's appointment screen. It only composes the widget tree; the state
/// and logic live in [DoctorAppointmentsCubit].
class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DoctorAppointmentsCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
          builder: (context, state) {
            return DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Mis Citas',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppointmentsTabs(),
                  Expanded(
                    child: state.isLoading
                        ? const AppointmentsLoading()
                        : state.loadError != null
                            ? AppointmentsError(cubit: cubit)
                            : TabBarView(
                                children: [
                                  AppointmentsList(
                                    appointments: state.todayAppointments,
                                    onRefresh: cubit.loadAppointments,
                                  ),
                                  AppointmentsList(
                                    appointments: state.upcomingAppointments,
                                    onRefresh: cubit.loadAppointments,
                                  ),
                                  AppointmentsList(
                                    appointments: state.pastAppointments,
                                    onRefresh: cubit.loadAppointments,
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
