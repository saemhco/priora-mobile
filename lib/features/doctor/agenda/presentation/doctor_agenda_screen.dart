import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/agenda/data/availability_service.dart';
import 'package:priora/features/doctor/agenda/data/models/weekly_schedule_model.dart';
import 'package:priora/features/doctor/agenda/controller/agenda_cubit.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/delete_block_sheet.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/appointments/data/models/doctor_appointment_model.dart';
import 'package:priora/features/doctor/navigation/controller/doctor_navigation_controller.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/controller/places_state.dart';
import 'package:priora/features/doctor/places/data/models/place_model.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_skeletons.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

// ─── Color themes ────────────────────────────────────────────────────────────
class _MeetingTypeTheme {
  final Color primary;
  final Color lightBg;
  final Color mediumBg;
  final Color border;
  final Color text;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String badgeText;

  const _MeetingTypeTheme({
    required this.primary,
    required this.lightBg,
    required this.mediumBg,
    required this.border,
    required this.text,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.badgeText,
  });

  static const virtual = _MeetingTypeTheme(
    primary: Color(0xFF0256C2),
    lightBg: Color(0xFFEFF6FF),
    mediumBg: Color(0xFFDBEAFE),
    border: Color(0xFFBFDBFE),
    text: Color(0xFF1E40AF),
    iconColor: Color(0xFF0256C2),
    icon: Icons.videocam_rounded,
    label: 'Virtual',
    badgeText: 'Virtual',
  );

  static const inPerson = _MeetingTypeTheme(
    primary: Color(0xFF059669),
    lightBg: Color(0xFFECFDF5),
    mediumBg: Color(0xFFA7F3D0),
    border: Color(0xFF6EE7B7),
    text: Color(0xFF065F46),
    iconColor: Color(0xFF059669),
    icon: Icons.business_rounded,
    label: 'Presencial',
    badgeText: 'Presencial',
  );
}

// Virtual filter constant ID
const String _kVirtualFilterId = '__virtual__';

// ─── Screen ──────────────────────────────────────────────────────────────────
class DoctorAgendaScreen extends StatefulWidget {
  const DoctorAgendaScreen({super.key});

  @override
  State<DoctorAgendaScreen> createState() => _DoctorAgendaScreenState();
}

class _DoctorAgendaScreenState extends State<DoctorAgendaScreen> {
  static const List<String> _dayLabels = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  List<WeeklySchedule> _schedules = [];
  List<String> _hours = [];
  Set<String> _availableSlots = {};
  Map<String, String> _slotTypes = {}; // "col_row" -> "VIRTUAL" | "IN_PERSON"

  PlaceModel? _selectedPlace;
  bool _isLoadingBlocks = false;

  // Filter selection: null = todos, '__virtual__' = solo virtual, place ID = lugar específico
  String? _selectedFilterId;

  bool get _isVirtualSelected => _selectedFilterId == _kVirtualFilterId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadPlaces();
    _loadBlocks();
  }

  /// Recarga todos los datos de la agenda (lugares, bloques y citas).
  Future<void> _refreshData() async {
    await Future.wait([
      _loadBlocks(),
      context.read<DoctorAppointmentsCubit>().loadAppointments(),
    ]);
    _loadPlaces();
  }

  void _loadPlaces() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PlacesCubit>().loadPlaces(
            accessToken: authState.accessToken,
          );
    }
  }

  Future<void> _loadBlocks() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoadingBlocks = true);
    try {
      final service = getIt<AvailabilityService>();
      final schedules = await service.getMyWeekly(
        accessToken: authState.accessToken,
      );

      _applyFilter(schedules);
    } catch (e) {
      debugPrint('Error loading blocks: $e');
      setState(() {
        _schedules = [];
        _hours = [];
        _availableSlots = {};
        _slotTypes = {};
      });
    } finally {
      if (mounted) setState(() => _isLoadingBlocks = false);
    }
  }

  void _applyFilter(List<WeeklySchedule>? schedules) {
    final allSchedules = schedules ?? _schedules;
    _schedules = allSchedules;

    // Filter by filterId
    List<WeeklySchedule> filtered;
    if (_selectedFilterId == null) {
      // Show all
      filtered = allSchedules;
    } else if (_isVirtualSelected) {
      // Show only virtual
      filtered = allSchedules.where((s) => s.meetingType == 'VIRTUAL').toList();
    } else {
      // Show only IN_PERSON for the selected place
      filtered = allSchedules
          .where((s) => s.meetingType == 'IN_PERSON' && s.place?.id == _selectedFilterId)
          .toList();
    }

    if (filtered.isNotEmpty) {
      // Extract all unique start times sorted
      final sortedHours = filtered
          .map((s) => s.startTime)
          .toSet()
          .toList()
        ..sort();

      // Build slot set and type map
      final slots = <String>{};
      final types = <String, String>{};
      for (final s in filtered) {
        final col = s.dayOfWeek - 1; // 0=Mon .. 6=Sun
        final row = sortedHours.indexOf(s.startTime);
        if (row >= 0) {
          final key = '${col}_$row';
          slots.add(key);
          types[key] = s.meetingType;
        }
      }

      setState(() {
        _hours = sortedHours;
        _availableSlots = slots;
        _slotTypes = types;
      });
    } else {
      setState(() {
        _hours = [];
        _availableSlots = {};
        _slotTypes = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0256C2),
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildInfoBanner(),
              const SizedBox(height: 20),
              _buildTodayAppointments(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildDateNavigator(),
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [ 
        Text(
          'Priora',
          style: TextStyle(
            color: _MeetingTypeTheme.virtual.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
          builder: (context, state) {
            final photoUrl = state.profile?.profilePhotoUrl;
            final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
            // Al presionar el avatar se navega al tab de Perfil
            return GestureDetector(
              onTap: () =>
                  context.read<DoctorNavigationCubit>().changeIndex(3),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF059669), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'El paciente verá estos slots al reservar',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    // Las citas vienen del estado compartido del DoctorAppointmentsCubit,
    // que realiza una sola llamada a GET /appointments/doctor.
    return BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
      builder: (context, state) {
        final todayAppointments = state.todayAppointments;
        final upcomingAppointments = state.upcomingAppointments.take(5).toList();
        final isLoading = state.isLoading && todayAppointments.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Citas de hoy',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (todayAppointments.isNotEmpty)
                  GestureDetector(
                    // Va al tab de Citas, que muestra todas con su pestaña "Hoy"
                    onTap: () =>
                        context.read<DoctorNavigationCubit>().changeIndex(1),
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Color(0xFF0256C2),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const TodayAppointmentsSkeleton(),
              )
            else if (todayAppointments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available_rounded,
                        size: 32, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 8),
                      Text(
                        'Sin citas para hoy',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayAppointments.map((appt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAppointmentCard(appt),
              )),
            if (upcomingAppointments.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Próximas citas',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...upcomingAppointments.map((appt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAppointmentCard(appt, compact: true),
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(DoctorAppointment appt, {bool compact = false}) {
    final isPast = appt.status == 'COMPLETED' || appt.status == 'CANCELED';
    final isVirtual = appt.isVirtual;
    final theme = isVirtual
        ? _MeetingTypeTheme.virtual
        : _MeetingTypeTheme.inPerson;

    final Color statusColor;
    switch (appt.status) {
      case 'CONFIRMED':
        statusColor = const Color(0xFF059669);
        break;
      case 'PENDING':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'COMPLETED':
        statusColor = const Color(0xFF64748B);
        break;
      case 'CANCELED':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              appt.patient.initials,
              style: TextStyle(
                color: theme.primary,
                fontSize: compact ? 12 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      appt.patient.fullName,
                      style: TextStyle(
                        color: isPast ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVirtual ? Icons.videocam_rounded : Icons.business_rounded,
                            size: 10,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isVirtual ? 'Virtual' : 'Presencial',
                            style: TextStyle(
                              color: theme.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                      size: 13,
                      color: isPast ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      appt.formattedTime,
                      style: TextStyle(
                        color: isPast ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appt.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (appt.placeName != null && !isVirtual) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        appt.placeName!,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: compact ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<PlacesCubit, PlacesState>(
          builder: (context, state) {
            if (state is PlacesLoading && _selectedPlace == null && !_isVirtualSelected) {
              return _buildLocationSelector(
                label: 'Cargando lugares...',
                isLoading: true,
              );
            }

            final places = state is PlacesLoaded ? state.places : <PlaceModel>[];

            String label;
            IconData icon;
            String? subtitle;

            if (_isVirtualSelected) {
              label = 'Virtual';
              icon = Icons.videocam_rounded;
            } else if (_selectedFilterId == null) {
              label = 'Todos';
              icon = Icons.public_rounded;
              subtitle = 'Virtuales y presenciales';
            } else if (_selectedPlace != null) {
              label = _selectedPlace!.name;
              icon = Icons.local_hospital_rounded;
              subtitle = _selectedPlace!.locationLabel;
            } else if (places.isNotEmpty) {
              label = places.first.name;
              icon = Icons.local_hospital_rounded;
              subtitle = places.first.locationLabel;
            } else {
              label = 'Sin lugares registrados';
              icon = Icons.info_outline_rounded;
            }

            return GestureDetector(
              onTap: () => _showFilterPicker(context, places),
              child: _buildLocationSelector(
                label: label,
                subtitle: subtitle,
                icon: icon,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSelector({
    required String label,
    String? subtitle,
    IconData? icon,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const LocationSelectorSkeleton();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.location_on_outlined, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  void _showFilterPicker(BuildContext context, List<PlaceModel> places) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Filtrar disponibilidad',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // "Todos" option
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedFilterId == null
                          ? const Color(0xFF0256C2)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.public_rounded,
                      color: _selectedFilterId == null
                          ? Colors.white
                          : const Color(0xFF0256C2),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Todos',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text(
                    'Mostrar bloques virtuales y presenciales',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: _selectedFilterId == null
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0256C2), size: 22)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFilterId = null;
                      _selectedPlace = null;
                    });
                    Navigator.pop(ctx);
                    _applyFilter(null);
                  },
                ),
                const Divider(indent: 20, endIndent: 20),
                // Virtual option
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isVirtualSelected
                          ? const Color(0xFF0256C2)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.videocam_rounded,
                      color: _isVirtualSelected
                          ? Colors.white
                          : const Color(0xFF0256C2),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Virtual',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text(
                    'Mostrar solo bloques virtuales',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: _isVirtualSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0256C2), size: 22)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFilterId = _kVirtualFilterId;
                      _selectedPlace = null;
                    });
                    Navigator.pop(ctx);
                    _applyFilter(null);
                  },
                ),
                // Only show places section if there are places
                if (places.isNotEmpty) ...[
                  const Divider(indent: 20, endIndent: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'Lugares de atención',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...places.map((place) => ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _selectedPlace?.id == place.id
                            ? const Color(0xFF0256C2)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: _selectedPlace?.id == place.id
                            ? Colors.white
                            : const Color(0xFF0256C2),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      place.locationLabel,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: _selectedPlace?.id == place.id
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0256C2), size: 22)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedPlace = place;
                        _selectedFilterId = place.id;
                      });
                      Navigator.pop(ctx);
                      _applyFilter(null);
                    },
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDeleteBlockSheet(BuildContext context) async {
    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay bloques para eliminar'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<DeleteBlockSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DeleteBlockSheet(blocks: _schedules),
    );

    if (result == null || !result.success || result.blockId == null) return;
    if (!context.mounted) return;

    final cubit = context.read<AgendaCubit>();
    final deleteResult = await cubit.deleteBlock(result.blockId!);
    if (!context.mounted) return;

    if (deleteResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bloque eliminado correctamente'),
          backgroundColor: Color(0xFF475569),
        ),
      );
      await _loadBlocks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleteResult.message ?? 'Error al eliminar el bloque',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push<bool>('/create-block');
              if (result == true && mounted) {
                _loadData();
              }
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Crear bloque'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0256C2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openDeleteBlockSheet(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text('Eliminar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _formatWeekRange() {
    final now = DateTime.now();
    // Find Monday of the current week (weekday 1 = Monday)
    final daysFromMonday = now.weekday - DateTime.monday;
    final monday = now.subtract(Duration(days: daysFromMonday));
    final sunday = monday.add(const Duration(days: 6));

    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];

    if (monday.month == sunday.month) {
      return '${months[monday.month - 1]} ${monday.day}-${sunday.day}, ${monday.year}';
    } else {
      return '${months[monday.month - 1]} ${monday.day} - ${months[sunday.month - 1]} ${sunday.day}, ${sunday.year}';
    }
  }

  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF0256C2)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Text(
          _formatWeekRange(),
          style: TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF0256C2)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    if (_isLoadingBlocks && _hours.isEmpty) {
      return const AgendaCalendarSkeleton();
    }

    if (_hours.isEmpty && !_isLoadingBlocks) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                _isVirtualSelected
                    ? Icons.videocam_rounded
                    : _selectedPlace != null
                        ? Icons.business_rounded
                        : Icons.event_busy_rounded,
                size: 48,
                color: const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 12),
              Text(
                _isVirtualSelected
                    ? 'Sin bloques virtuales'
                    : _selectedPlace != null
                        ? 'Sin bloques en este lugar'
                        : 'Sin bloques de disponibilidad',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Crea tu primer bloque con el botón "Crear bloque"',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),
            ...List.generate(_hours.length, (rowIndex) => _buildTimeRow(rowIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      children: [
        const SizedBox(width: 60),
        ...List.generate(_dayLabels.length, (index) {
          final isToday = index == DateTime.now().weekday - 1; // highlight today
          return Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              color: isToday ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            ),
            child: Text(
              _dayLabels[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isToday ? const Color(0xFF0256C2) : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeRow(int rowIndex) {
    if (_hours.isEmpty) return const SizedBox.shrink();
    final time = _hours[rowIndex];
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            time,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...List.generate(_dayLabels.length, (colIndex) {
          final key = '${colIndex}_$rowIndex';
          final isAvailable = _availableSlots.contains(key);
          final slotType = _slotTypes[key];
          return _buildSlotCell(colIndex, rowIndex, isAvailable, slotType);
        }),
      ],
    );
  }

  Widget _buildSlotCell(int colIndex, int rowIndex, bool isAvailable, String? slotType) {
    // Determine theme based on slot type
    final theme = slotType == 'IN_PERSON'
        ? _MeetingTypeTheme.inPerson
        : _MeetingTypeTheme.virtual;

    final isVirtual = slotType == 'VIRTUAL' || slotType == null;

    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F5F9), width: 0.5),
        color: isAvailable ? theme.lightBg : const Color(0xFFF8FAFC),
      ),
      child: isAvailable
          ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: theme.primary, width: 3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVirtual ? Icons.videocam_rounded : Icons.business_rounded,
                    size: 14,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVirtual ? 'Virtual' : 'Presencial',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(_MeetingTypeTheme.virtual.primary, Icons.videocam_rounded, 'Virtual'),
        const SizedBox(width: 20),
        _legendDot(_MeetingTypeTheme.inPerson.primary, Icons.business_rounded, 'Presencial'),
        const SizedBox(width: 20),
        _legendDot(const Color(0xFFE2E8F0), null, 'Sin disponibilidad'),
      ],
    );
  }

  Widget _legendDot(Color color, IconData? icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 14, color: color)
        else
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
