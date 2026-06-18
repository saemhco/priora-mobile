import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class NextAppointmentCard extends StatefulWidget {
  const NextAppointmentCard({super.key});

  @override
  State<NextAppointmentCard> createState() => _NextAppointmentCardState();
}

class _NextAppointmentCardState extends State<NextAppointmentCard> {
  late Future<List<dynamic>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final repository = RepositoryProvider.of<AuthRepository>(context);
      _appointmentsFuture = repository.getMyAppointments(accessToken: authState.accessToken);
    } else {
      _appointmentsFuture = Future.value([]);
    }
  }

  String _formatDateTime(String datetimeStr) {
    final dt = DateTime.tryParse(datetimeStr)?.toLocal();
    if (dt == null) return datetimeStr;

    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final day = dt.day;
    final month = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    
    // Check if it is today or tomorrow
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final appointmentDay = DateTime(dt.year, dt.month, dt.day);

    if (appointmentDay == today) {
      return 'Hoy, $hour:$minute $period';
    } else if (appointmentDay == tomorrow) {
      return 'Mañana, $hour:$minute $period';
    }

    return '$day $month, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<dynamic>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0256C2),
              ),
            ),
          );
        }

        final appointments = snapshot.data ?? [];
        
        // Filter active upcoming appointments
        final activeAppointments = appointments.where((app) {
          final status = app['status']?.toString().toUpperCase() ?? '';
          if (status == 'CANCELLED') return false;

          final datetimeStr = app['datetime']?.toString() ?? '';
          final dt = DateTime.tryParse(datetimeStr);
          if (dt == null) return false;

          // Keep appointments that are not older than 2 hours
          return dt.isAfter(DateTime.now().subtract(const Duration(hours: 2)));
        }).toList();

        // Sort by datetime ascending
        activeAppointments.sort((a, b) {
          final dtA = DateTime.tryParse(a['datetime']?.toString() ?? '') ?? DateTime.now();
          final dtB = DateTime.tryParse(b['datetime']?.toString() ?? '') ?? DateTime.now();
          return dtA.compareTo(dtB);
        });

        if (activeAppointments.isEmpty) {
          // No upcoming appointments: Render a friendly message placeholder
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF64748B),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'No tienes citas próximas',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cuando reserves una cita, aparecerá aquí para que puedas hacerle seguimiento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        // Get the closest upcoming appointment
        final nextApp = activeAppointments.first;
        final docData = nextApp['doctor'] ?? nextApp['professional'] ?? nextApp['professionalProfile'];
        final docName = docData != null
            ? '${docData['firstName'] ?? docData['name'] ?? ''} ${docData['lastName'] ?? ''}'.trim()
            : 'Médico Especialista';
        final docPhoto = docData != null ? docData['profilePhotoUrl'] : null;
        final specialty = nextApp['specialty']?.toString() ?? 'Especialista';
        final meetingType = nextApp['meetingType']?.toString().toUpperCase() ?? 'VIRTUAL';
        final placeData = nextApp['place'];
        final placeName = placeData != null ? placeData['name']?.toString() : null;

        final hasDocPhoto = docPhoto != null && docPhoto.toString().isNotEmpty;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRÓXIMA CITA',
                      style: TextStyle(
                        color: Color(0xFF00CBB8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00CBB8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        nextApp['status']?.toString() ?? 'Confirmada',
                        style: const TextStyle(
                          color: Color(0xFF00CBB8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Doctor Info Row
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                    ),
                    child: ClipOval(
                      child: hasDocPhoto
                          ? Image.network(
                              docPhoto.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                color: Color(0xFF64748B),
                                size: 30,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Color(0xFF64748B),
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docName,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specialty,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Sub-card with Details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Date Column
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF0256C2),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FECHA',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDateTime(nextApp['datetime']?.toString() ?? ''),
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                    const SizedBox(width: 12),
                    // Location Column
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            meetingType == 'VIRTUAL' ? Icons.videocam_outlined : Icons.location_on_outlined,
                            color: const Color(0xFF0256C2),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MODALIDAD',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  meetingType == 'VIRTUAL' ? 'Teleconsulta' : (placeName ?? 'Presencial'),
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
