import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/cancel_appointment_result.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_theme.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/cancel_appointment_sheet.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/register_attendance_sheet.dart';

/// Card of a doctor's appointment with actions to record care/cancel.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({required this.appointment, super.key});

  final DoctorAppointment appointment;

  Future<void> _openRegisterAttendance(BuildContext context) async {
    final cubit = context.read<DoctorAppointmentsCubit>();
    final registered = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => RegisterAttendanceSheet(
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

  Future<void> _openCancelAppointment(BuildContext context) async {
    final cubit = context.read<DoctorAppointmentsCubit>();
    final result = await showModalBottomSheet<CancelAppointmentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CancelAppointmentSheet(
        appointment: appointment,
        onCancel: (reason) => cubit.cancelAppointment(
          appointmentId: appointment.id,
          cancelReason: reason,
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Cita cancelada correctamente'
              : (result.message ?? 'No se pudo cancelar la cita'),
        ),
        backgroundColor: result.success
            ? const Color(0xFF475569)
            : const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = appointment.status == 'COMPLETED';
    final isCanceled = appointment.status == 'CANCELED';
    final isPast = isCompleted || isCanceled;
    final textColor = isPast
        ? const Color(0xFF94A3B8)
        : const Color(0xFF1E293B);
    final subtitleColor = isPast
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final avatarColor = avatarColorFor(appointment.patient.fullName);

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
              _buildAvatar(avatarColor),
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
                        _buildModalityChip(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(isPast),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            formatAppointmentDateTime(appointment),
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
            _buildActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
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

  Widget _buildModalityChip() {
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

  Widget _buildStatusBadge(bool isPast) {
    Color bgColor;
    Color textColor;
    switch (appointment.status) {
      case 'CONFIRMED':
        bgColor = const Color(0xFFE0F7F6);
        textColor = const Color(0xFF0C6159);
      case 'PENDING':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
      case 'CANCELED':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
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

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openRegisterAttendance(context),
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
          onPressed: () => _openCancelAppointment(context),
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
    );
  }
}
