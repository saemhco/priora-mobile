import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';
import 'package:priora/features/patient/appointments/controller/appointments_controller.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/doctor_card.dart';
import 'package:priora/features/patient/appointments/presentation/confirm_booking_screen.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class TriageResultView extends StatelessWidget {
  final TriageState state;
  final PatientNavigationCubit navigationCubit;

  const TriageResultView({
    super.key,
    required this.state,
    required this.navigationCubit,
  });

  @override
  Widget build(BuildContext context) {
    // Priority color mapping
    Color priorityColor;
    Color priorityBgColor;
    String priorityText;
    IconData priorityIcon;
    String prioritySubtitle;

    final priorityUpper = state.priority?.toUpperCase() ?? 'LOW';

    if (priorityUpper == 'CRITICAL' || priorityUpper == 'HIGH') {
      priorityColor = const Color(0xFFEF4444); // Red
      priorityBgColor = const Color(0xFFFEE2E2);
      priorityText = 'CRITICAL';
      priorityIcon = Icons.warning_amber_rounded;
      prioritySubtitle = 'Atención médica inmediata requerida';
    } else if (priorityUpper == 'MEDIUM') {
      priorityColor = const Color(0xFFF97316); // Orange
      priorityBgColor = const Color(0xFFFFEDD5);
      priorityText = 'MEDIUM';
      priorityIcon = Icons.warning_amber_rounded;
      prioritySubtitle = 'Requiere atención pronta';
    } else {
      priorityColor = const Color(0xFF10B981); // Green
      priorityBgColor = const Color(0xFFD1FAE5);
      priorityText = 'LOW';
      priorityIcon = Icons.check_circle_outline_rounded;
      prioritySubtitle = 'Atención general o cuidados en casa';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Resultado de Triaje',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Hemos analizado tus síntomas con precisión clínica.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Priority Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NIVEL DE PRIORIDAD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: priorityBgColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  priorityIcon,
                                  color: priorityColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  priorityText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: priorityColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            prioritySubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Patient Safe Message / AI Recommendation Card
                    if (state.patientSafeMessage != null &&
                        state.patientSafeMessage!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          '"${state.patientSafeMessage}"',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Suggested Specialties Section
                    Row(
                      children: const [
                        Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF0256C2),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Especialidades Sugeridas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Specialties Cards List
                    if (state.suggestedSpecialties.isEmpty)
                      const Text(
                        'No hay especialidades específicas sugeridas.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.3,
                            ),
                        itemCount: state.suggestedSpecialties.length,
                        itemBuilder: (context, index) {
                          final specialtyName =
                              state.suggestedSpecialties[index];

                          // Custom Icon/Bg color per specialty type if wanted, or standard blue
                          final isFirst = index == 0;
                          final cardIcon = isFirst
                              ? Icons.favorite_border_rounded
                              : Icons.health_and_safety_outlined;
                          final cardColor = isFirst
                              ? const Color(0xFFEEF2FF)
                              : const Color(0xFFE0F7FA);
                          final iconColor = isFirst
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF00ACC1);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    cardIcon,
                                    color: iconColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  specialtyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFirst
                                      ? 'Alta prioridad'
                                      : 'Evaluación inicial',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),

                    // Action Button: Agendar cita
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                SuggestedAppointmentsBottomSheet(
                                  suggestedSpecialties:
                                      state.suggestedSpecialties,
                                  navigationCubit: navigationCubit,
                                ),
                          );
                        },
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'Agendar cita',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0256C2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action Button: Ver historial de triaje
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          navigationCubit.changeIndex(1);
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text(
                          'Ver historial de triaje',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0256C2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dotted Info card at the bottom
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Este resultado es una orientación basada en tus respuestas. En caso de emergencia extrema, acude al centro de salud más cercano.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestedAppointmentsBottomSheet extends StatefulWidget {
  final List<String> suggestedSpecialties;
  final PatientNavigationCubit navigationCubit;

  const SuggestedAppointmentsBottomSheet({
    super.key,
    required this.suggestedSpecialties,
    required this.navigationCubit,
  });

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

  void _confirmBooking(BuildContext context, DoctorModel doctor, String slot) {
    Navigator.of(context).push(
      MaterialPageRoute(
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
                          padding: const EdgeInsets.only(right: 8.0),
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
                            padding: const EdgeInsets.only(right: 8.0),
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
                              padding: EdgeInsets.all(40.0),
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
