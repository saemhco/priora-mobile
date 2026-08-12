import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_theme.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// Card of a doctor's appointment for the "Today's Appointments" section.
class AgendaAppointmentCard extends StatelessWidget {
  const AgendaAppointmentCard({
    required this.appointment,
    super.key,
    this.compact = false,
  });

  final DoctorAppointment appointment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPast =
        appointment.status == 'COMPLETED' || appointment.status == 'CANCELED';
    final isVirtual = appointment.isVirtual;
    final theme = isVirtual
        ? MeetingTypeTheme.virtual
        : MeetingTypeTheme.inPerson;

    final Color statusColor;
    switch (appointment.status) {
      case 'CONFIRMED':
        statusColor = const Color(0xFF059669);
      case 'PENDING':
        statusColor = const Color(0xFFF59E0B);
      case 'COMPLETED':
        statusColor = const Color(0xFF64748B);
      case 'CANCELED':
        statusColor = const Color(0xFFEF4444);
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
              appointment.patient.initials,
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
                      appointment.patient.fullName,
                      style: TextStyle(
                        color: isPast
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF1E293B),
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVirtual
                                ? Icons.videocam_rounded
                                : Icons.business_rounded,
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
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: isPast
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.formattedTime,
                      style: TextStyle(
                        color: isPast
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (appointment.placeName != null && !isVirtual) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.placeName!,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
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
}
