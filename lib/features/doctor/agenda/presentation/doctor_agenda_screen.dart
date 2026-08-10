import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/agenda_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_action_buttons.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_calendar_view.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_date_navigator.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_header.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_info_banner.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_legend.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/location_filter_section.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/today_appointments_section.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Doctor's agenda screen. It only composes the widget tree; the status and
/// logic live in [AgendaController].
class DoctorAgendaScreen extends StatefulWidget {
  const DoctorAgendaScreen({super.key});

  @override
  State<DoctorAgendaScreen> createState() => _DoctorAgendaScreenState();
}

class _DoctorAgendaScreenState extends State<DoctorAgendaScreen> {
  late final AgendaController _controller;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState is AuthAuthenticated
        ? authState.accessToken
        : '';
    _controller = AgendaController(
      repository: getIt<AgendaRepository>(),
      placesCubit: context.read<PlacesCubit>(),
      appointmentsCubit: context.read<DoctorAppointmentsCubit>(),
      accessToken: accessToken,
    );
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF0256C2),
              onRefresh: _controller.refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const AgendaHeader(),
                    const SizedBox(height: 20),
                    const AgendaInfoBanner(),
                    const SizedBox(height: 20),
                    const TodayAppointmentsSection(),
                    const SizedBox(height: 20),
                    LocationFilterSection(controller: _controller),
                    const SizedBox(height: 16),
                    AgendaActionButtons(controller: _controller),
                    const SizedBox(height: 24),
                    AgendaDateNavigator(
                      weekRange: _controller.formatWeekRange(),
                    ),
                    const SizedBox(height: 16),
                    AgendaCalendarView(controller: _controller),
                    const SizedBox(height: 16),
                    const AgendaLegend(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
