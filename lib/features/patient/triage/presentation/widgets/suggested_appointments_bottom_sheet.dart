import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/appointments/domain/interfaces/appointments_repository.dart';
import 'package:priora/features/patient/appointments/domain/models/doctor.dart';
import 'package:priora/features/patient/appointments/presentation/confirm_booking_screen.dart';
import 'package:priora/features/patient/appointments/presentation/controller/appointments_controller.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/doctor_card.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Bottom sheet con la lista de especialistas disponibles, filtrable por las
/// especialidades sugeridas por el triaje.
class SuggestedAppointmentsBottomSheet extends StatefulWidget {
  const SuggestedAppointmentsBottomSheet({
    required this.suggestedSpecialties,
    required this.navigationCubit,
    super.key,
  });

  final List<String> suggestedSpecialties;
  final PatientNavigationCubit navigationCubit;

  @override
  State<SuggestedAppointmentsBottomSheet> createState() =>
      _SuggestedAppointmentsBottomSheetState();
}

class _SuggestedAppointmentsBottomSheetState
    extends State<SuggestedAppointmentsBottomSheet> {
  AppointmentsController? _controller;
  String _selectedFilter = 'Todos';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final authState = context.read<AuthBloc>().state;
      final accessToken = authState is AuthAuthenticated
          ? authState.accessToken
          : '';
      final repository = context.read<AppointmentsRepository>();
      final triageRepository = context.read<TriageRepository>();

      _controller = AppointmentsController(
        repository: repository,
        triageRepository: triageRepository,
        accessToken: accessToken,
      );

      // Pre-select the first suggested specialty if available
      if (widget.suggestedSpecialties.isNotEmpty) {
        _selectedFilter = widget.suggestedSpecialties.first;
        _controller!.selectedSpecialty = _selectedFilter;
      }

      _controller!.fetchAvailableBookings();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _confirmBooking(BuildContext context, Doctor doctor, String slot) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmBookingScreen(
          doctor: doctor,
          slot: slot,
          controller: _controller!,
          navigationCubit: widget.navigationCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0256C2)),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _controller!,
          builder: (context, child) {
            final doctors = _controller!.filteredDoctors;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Especialistas Disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.suggestedSpecialties.isEmpty
                                  ? 'Encuentra y agenda tu cita'
                                  : 'Filtrado por especialidades sugeridas',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter Chips
                if (widget.suggestedSpecialties.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Option: Todos
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todos'),
                            selected: _selectedFilter == 'Todos',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = 'Todos';
                                  _controller!.selectedSpecialty = 'Todos';
                                });
                              }
                            },
                            selectedColor: const Color(0xFF0256C2),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _selectedFilter == 'Todos'
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedFilter == 'Todos'
                                    ? Colors.transparent
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                        // Suggested chips
                        ...widget.suggestedSpecialties.map((spec) {
                          final isSelected =
                              _selectedFilter.toLowerCase() ==
                              spec.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.stars_rounded,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(spec),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedFilter = spec;
                                    _controller!.selectedSpecialty = spec;
                                  });
                                }
                              },
                              selectedColor: const Color(0xFF0256C2),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Doctors List
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: _controller!.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                color: Color(0xFF0256C2),
                              ),
                            ),
                          )
                        : doctors.isEmpty
                        ? Container(
                            height: 180,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_search_rounded,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay especialistas disponibles para $_selectedFilter',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return DoctorCard(
                                doctor: doctor,
                                onSelectSlot: (slot) {
                                  _controller!.selectTimeSlot(doctor.id, slot);
                                  // Close bottom sheet first
                                  Navigator.pop(context);
                                  // Push confirm screen
                                  _confirmBooking(context, doctor, slot);
                                },
                                onViewCalendar: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Visualización detallada de calendario disponible próximamente.',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
