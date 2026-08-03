import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/appointments/data/models/doctor_appointment_model.dart';

const List<Color> _avatarPalette = [
  Color(0xFF3B82F6),
  Color(0xFF059669),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF06B6D4),
];

Color _avatarColorFor(String name) {
  var hash = 0;
  for (final code in name.codeUnits) {
    hash = (hash + code) % 997;
  }
  return _avatarPalette[hash % _avatarPalette.length];
}

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  Future<void> _openRegisterAttendance(
    BuildContext context,
    DoctorAppointment appointment,
  ) async {
    final cubit = context.read<DoctorAppointmentsCubit>();
    final registered = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _RegisterAttendanceSheet(
        appointment: appointment,
        onRegister: (note) => cubit.registerAttendance(
          appointmentId: appointment.id,
          attendanceNote: note,
        ),
      ),
    );

    if (registered == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención registrada correctamente'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
  }

  Future<void> _openCancelAppointment(
    BuildContext context,
    DoctorAppointment appointment,
  ) async {
    final cubit = context.read<DoctorAppointmentsCubit>();
    final cancelled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CancelAppointmentSheet(
        appointment: appointment,
        onCancel: (reason) => cubit.cancelAppointment(
          appointmentId: appointment.id,
          cancelReason: reason,
        ),
      ),
    );

    if (cancelled == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita cancelada correctamente'),
          backgroundColor: Color(0xFF475569),
        ),
      );
    }
  }

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
                  _buildTabs(),
                  Expanded(
                    child: state.isLoading
                        ? _buildLoading()
                        : state.loadError != null
                            ? _buildError(cubit)
                            : TabBarView(
                                children: [
                                  _buildAppointmentsList(
                                    cubit,
                                    state.todayAppointments,
                                  ),
                                  _buildAppointmentsList(
                                    cubit,
                                    state.upcomingAppointments,
                                  ),
                                  _buildAppointmentsList(
                                    cubit,
                                    state.pastAppointments,
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

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0256C2)),
    );
  }

  Widget _buildError(DoctorAppointmentsCubit cubit) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              cubit.state.loadError ?? 'Error al cargar las citas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cubit.loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0256C2),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Hoy'),
          Tab(text: 'Próximas'),
          Tab(text: 'Pasadas'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
    DoctorAppointmentsCubit cubit,
    List<DoctorAppointment> appointments,
  ) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF0256C2),
        onRefresh: cubit.loadAppointments,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 40,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No hay citas',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desliza hacia abajo para actualizar',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF0256C2),
      onRefresh: cubit.loadAppointments,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            _buildAppointmentCard(appointments[index]),
      ),
    );
  }

  Widget _buildAppointmentCard(DoctorAppointment appointment) {
    final isCompleted = appointment.status == 'COMPLETED';
    final isCanceled = appointment.status == 'CANCELED';
    final isPast = isCompleted || isCanceled;
    final textColor =
        isPast ? const Color(0xFF94A3B8) : const Color(0xFF1E293B);
    final subtitleColor =
        isPast ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final avatarColor = _avatarColorFor(appointment.patient.fullName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(appointment, avatarColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.patient.fullName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildModalityChip(appointment),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(appointment, isPast),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            _formatDateTime(appointment),
            subtitleColor,
          ),
          if (!appointment.isVirtual && appointment.placeName != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.location_on_outlined,
              appointment.placeName!,
              subtitleColor,
            ),
          ],
          if (!isPast) ...[
            const SizedBox(height: 16),
            _buildActions(appointment),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(DoctorAppointment appointment, Color color) {
    final photoUrl = appointment.patient.profilePhotoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: hasPhoto ? color.withValues(alpha: 0.15) : color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Text(
                appointment.patient.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Text(
              appointment.patient.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildModalityChip(DoctorAppointment appointment) {
    final isVirtual = appointment.isVirtual;
    final color = isVirtual ? const Color(0xFF059669) : const Color(0xFF64748B);
    final icon = isVirtual ? Icons.videocam_rounded : Icons.map_rounded;
    final label = isVirtual ? 'Virtual' : 'Presencial';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DoctorAppointment appointment, bool isPast) {
    Color bgColor;
    Color textColor;
    switch (appointment.status) {
      case 'CONFIRMED':
        bgColor = const Color(0xFFE0F7F6);
        textColor = const Color(0xFF0C6159);
        break;
      case 'PENDING':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        break;
      case 'CANCELED':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF94A3B8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        appointment.statusLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(DoctorAppointment appointment) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openRegisterAttendance(context, appointment),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
              label: const Text('Registrar atención'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _openCancelAppointment(context, appointment),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              minimumSize: const Size(44, 44),
            ),
            child: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DoctorAppointment appointment) {
    if (appointment.isToday) {
      return 'Hoy, ${appointment.formattedTime}';
    }
    return '${appointment.formattedDate}, ${appointment.formattedTime}';
  }
}

// ─── Bottom sheet: Registrar atención (solo UI) ──────────────────────────────
class _RegisterAttendanceSheet extends StatefulWidget {
  final DoctorAppointment appointment;
  final Future<RegisterAttendanceResult> Function(String note) onRegister;

  const _RegisterAttendanceSheet({
    required this.appointment,
    required this.onRegister,
  });

  @override
  State<_RegisterAttendanceSheet> createState() =>
      _RegisterAttendanceSheetState();
}

class _RegisterAttendanceSheetState extends State<_RegisterAttendanceSheet> {
  static const int _minChars = 10;

  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  String get _note => _noteController.text.trim();

  bool get _isValid => _note.length >= _minChars;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await widget.onRegister(_note);
    if (!mounted) return;

    if (result.success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = result.message ??
            'Error al registrar la atención. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isVirtual = appointment.isVirtual;
    final avatarColor = _avatarColorFor(appointment.patient.fullName);
    final noteColor = _note.isEmpty
        ? const Color(0xFF94A3B8)
        : _isValid
            ? const Color(0xFF059669)
            : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Registrar atención',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Confirma que la cita fue atendida y añade una nota de evidencia.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            // Resumen de la cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      appointment.patient.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patient.fullName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isVirtual ? 'Virtual' : 'Presencial'} · '
                          '${_formatSheetDateTime(appointment)}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.statusLabel,
                      style: const TextStyle(
                        color: Color(0xFF0256C2),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nota de atención
            TextField(
              controller: _noteController,
              maxLines: 5,
              minLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nota de atención',
                alignLabelWithHint: true,
                hintText: 'Describe brevemente cómo se realizó la atención…',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0256C2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${_note.length} caracteres',
                  style: TextStyle(
                    color: noteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_note.isNotEmpty && !_isValid) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '· mínimo 10 caracteres',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isValid && !_isSubmitting ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Registrando…' : 'Confirmar atención',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0256C2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  disabledBackgroundColor: const Color(0xFFBFDBFE),
                  disabledForegroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSheetDateTime(DoctorAppointment appointment) {
    if (appointment.isToday) {
      return 'Hoy, ${appointment.formattedTime}';
    }
    return '${appointment.formattedDate}, ${appointment.formattedTime}';
  }
}

// ─── Bottom sheet: Cancelar cita (solo UI) ──────────────────────────────────
class _CancelAppointmentSheet extends StatefulWidget {
  static const List<String> quickReasons = [
    'El paciente solicitó reprogramar',
    'Emergencia del profesional',
    'Motivo personal',
    'El paciente no asistirá',
  ];

  final DoctorAppointment appointment;
  final Future<CancelAppointmentResult> Function(String? reason) onCancel;

  const _CancelAppointmentSheet({
    required this.appointment,
    required this.onCancel,
  });

  @override
  State<_CancelAppointmentSheet> createState() =>
      _CancelAppointmentSheetState();
}

class _CancelAppointmentSheetState extends State<_CancelAppointmentSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final reason = _reasonController.text.trim();
    final result = await widget.onCancel(reason.isEmpty ? null : reason);
    if (!mounted) return;

    if (result.success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = result.message ??
            'Error al cancelar la cita. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isVirtual = appointment.isVirtual;
    final avatarColor = _avatarColorFor(appointment.patient.fullName);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cancelar cita',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'La cita se cancelará y el paciente será notificado. Solo se puede cancelar si faltan más de 1 hora.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            // Resumen de la cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      appointment.patient.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patient.fullName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isVirtual ? 'Virtual' : 'Presencial'} · '
                          '${_formatSheetDateTime(appointment)}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.statusLabel,
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Motivo de cancelación (opcional)
            const Text(
              'Motivo de cancelación (opcional)',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _CancelAppointmentSheet.quickReasons.map((reason) {
                final isSelected =
                    _reasonController.text.trim() == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _reasonController.text = isSelected ? '' : reason;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      reason,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              minLines: 2,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Detalla el motivo',
                alignLabelWithHint: true,
                hintText: 'Escribe el motivo de la cancelación…',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.close_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Cancelando…' : 'Cancelar cita',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  disabledBackgroundColor: const Color(0xFFFCA5A5),
                  disabledForegroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSheetDateTime(DoctorAppointment appointment) {
    if (appointment.isToday) {
      return 'Hoy, ${appointment.formattedTime}';
    }
    return '${appointment.formattedDate}, ${appointment.formattedTime}';
  }
}
