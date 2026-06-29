import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/appointments/controller/appointments_controller.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/appointment_search_bar.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/specialty_filter_chips.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/doctor_card.dart';
import 'package:priora/features/patient/appointments/presentation/widgets/notification_banner.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/appointments/presentation/confirm_booking_screen.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen> {
  AppointmentsController? _controller;

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
      _controller!.fetchAvailableBookings();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _confirmBooking(BuildContext context, DoctorModel doctor, String slot) {
    final navigationCubit = context.read<PatientNavigationCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmBookingScreen(
          doctor: doctor,
          slot: slot,
          controller: _controller!,
          navigationCubit: navigationCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0256C2)),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, child) {
        final doctors = _controller!.filteredDoctors;
        final myAppointments = _controller!.myAppointments;

        return DefaultTabController(
          key: ValueKey(_controller!.selectedSubTab),
          initialIndex: _controller!.selectedSubTab,
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Citas médicas',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Gestiona tus citas preventivas o agenda con un especialista.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TabBar(
                            onTap: (index) {
                              _controller!.selectedSubTab = index;
                            },
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            dividerColor: Colors.transparent,
                            labelColor: const Color(0xFF0256C2),
                            unselectedLabelColor: const Color(0xFF64748B),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            tabs: const [
                              Tab(text: 'Disponibles'),
                              Tab(text: 'Mis Citas'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Citas disponibles
                        RefreshIndicator(
                          onRefresh: () async {
                            await _controller!.fetchAvailableBookings();
                          },
                          color: const Color(0xFF0256C2),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: !_controller!.isTriageCompleted
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEFF6FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.calendar_month_rounded,
                                            color: Color(0xFF1D4ED8),
                                            size: 48,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'No puedes reservar en este momento',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Para agendar una nueva cita, necesitas completar una evaluación de triaje. Esto nos ayuda a derivarte con el especialista correcto.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF64748B),
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              context
                                                  .read<
                                                    PatientNavigationCubit
                                                  >()
                                                  .changeIndex(1);
                                            },
                                            icon: const Icon(
                                              Icons.add_box_outlined,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Nueva evaluación IA',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0256C2,
                                              ),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              context
                                                  .read<
                                                    PatientNavigationCubit
                                                  >()
                                                  .changeIndex(0);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Color(0xFF0256C2),
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Volver al inicio',
                                              style: TextStyle(
                                                color: Color(0xFF0256C2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppointmentSearchBar(
                                        onChanged:
                                            _controller!.updateSearchQuery,
                                      ),
                                      const SizedBox(height: 16),
                                      SpecialtyFilterChips(
                                        specialties: _controller!.specialties,
                                        selectedSpecialty:
                                            _controller!.selectedSpecialty,
                                        onSelected:
                                            _controller!.selectSpecialty,
                                      ),
                                      const SizedBox(height: 20),
                                      if (_controller!.isLoading)
                                        const DoctorListSkeleton()
                                      else if (_controller!.errorMessage !=
                                          null)
                                        Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            _controller!.errorMessage!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      else if (doctors.isEmpty)
                                        Container(
                                          height: 150,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'No se encontraron especialistas',
                                            style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      else
                                        ...doctors.map(
                                          (doctor) => DoctorCard(
                                            doctor: doctor,
                                            onSelectSlot: (slot) {
                                              _controller!.selectTimeSlot(
                                                doctor.id,
                                                slot,
                                              );
                                              _confirmBooking(
                                                context,
                                                doctor,
                                                slot,
                                              );
                                            },
                                            onViewCalendar: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Abriendo calendario de ${doctor.name}',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      NotificationBanner(
                                        enabled:
                                            _controller!.notificationsEnabled,
                                        onTap: () {
                                          _controller!.toggleNotifications();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                _controller!
                                                        .notificationsEnabled
                                                    ? 'Notificaciones activadas'
                                                    : 'Notificaciones desactivadas',
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  _controller!
                                                      .notificationsEnabled
                                                  ? const Color(0xFF0E5FD9)
                                                  : const Color(0xFF64748B),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                          ),
                        ),

                        // Tab 2: Mis citas
                        RefreshIndicator(
                          onRefresh: () async {
                            await _controller!.fetchMyAppointments();
                          },
                          color: const Color(0xFF0256C2),
                          child: _controller!.isLoadingMyAppointments
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0256C2),
                                  ),
                                )
                              : myAppointments.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  children: [
                                    Container(
                                      height: 350,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEFF6FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.calendar_month_outlined,
                                              color: Color(0xFF3B82F6),
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'No tienes citas programadas',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Reserva una cita disponible con un especialista para iniciar tu cuidado preventivo.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF64748B),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  itemCount: myAppointments.length,
                                  itemBuilder: (context, index) {
                                    final appointment = myAppointments[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFF1F5F9),
                                          width: 1.5,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x050F172A),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.network(
                                              appointment['doctorAvatar'] ?? '',
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: const Color(
                                                      0xFFEFF6FF,
                                                    ),
                                                    width: 56,
                                                    height: 56,
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Color(0xFF3B82F6),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        appointment['doctorName'] ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF0F172A,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            appointment['isVirtual'] ==
                                                                true
                                                            ? const Color(
                                                                0xFFECFDF5,
                                                              )
                                                            : const Color(
                                                                0xFFEFF6FF,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        appointment['isVirtual'] ==
                                                                true
                                                            ? 'Virtual'
                                                            : 'Presencial',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              appointment['isVirtual'] ==
                                                                  true
                                                              ? const Color(
                                                                  0xFF059669,
                                                                )
                                                              : const Color(
                                                                  0xFF2563EB,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  appointment['doctorSpecialty'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Divider(
                                                  color: Color(0xFFF1F5F9),
                                                  height: 1,
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .calendar_today_rounded,
                                                      size: 14,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      appointment['formattedDate'] ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF334155,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    const Icon(
                                                      Icons.access_time_rounded,
                                                      size: 14,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      appointment['formattedTime'] ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF334155,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DoctorListSkeleton extends StatefulWidget {
  const DoctorListSkeleton({super.key});

  @override
  State<DoctorListSkeleton> createState() => _DoctorListSkeletonState();
}

class _DoctorListSkeletonState extends State<DoctorListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: Column(
        children: List.generate(2, (index) => _buildSkeletonCard()),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
