import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentsList(_todayAppointments),
                  _buildAppointmentsList(_upcomingAppointments),
                  _buildAppointmentsList(_pastAppointments),
                ],
              ),
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
        controller: _tabController,
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
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Hoy'),
          Tab(text: 'Próximas'),
          Tab(text: 'Pasadas'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentData> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No hay citas',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
    );
  }

  Widget _buildAppointmentCard(AppointmentData appointment) {
    final isCompleted = appointment.status == 'Completada';
    final textColor = isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B);
    final subtitleColor = isCompleted ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

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
              _buildAvatar(appointment.initials, appointment.avatarColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          appointment.patientName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildModalityChip(appointment.modality, appointment.isVirtual),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(appointment.status, isCompleted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.calendar_today_outlined, appointment.dateTime, subtitleColor),
          const SizedBox(height: 6),
          if (appointment.isVirtual && appointment.meetingLink != null)
            _buildInfoRow(Icons.link_rounded, appointment.meetingLink!, const Color(0xFF0256C2)),
          if (!appointment.isVirtual && appointment.location != null)
            _buildInfoRow(Icons.location_on_outlined, appointment.location!, subtitleColor),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildModalityChip(String modality, bool isVirtual) {
    final color = isVirtual ? const Color(0xFF059669) : const Color(0xFF64748B);
    final icon = isVirtual ? Icons.videocam_rounded : Icons.map_rounded;
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
            modality,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isCompleted) {
    Color bgColor;
    Color textColor;
    if (status == 'Confirmada') {
      bgColor = const Color(0xFFE0F7F6);
      textColor = const Color(0xFF0C6159);
    } else if (status == 'Pendiente') {
      bgColor = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF64748B);
    } else {
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
        status,
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
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0256C2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            child: const Text('Registrar atención'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
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

class AppointmentData {
  final String initials;
  final Color avatarColor;
  final String patientName;
  final String modality;
  final bool isVirtual;
  final String status;
  final String dateTime;
  final String? meetingLink;
  final String? location;

  const AppointmentData({
    required this.initials,
    required this.avatarColor,
    required this.patientName,
    required this.modality,
    required this.isVirtual,
    required this.status,
    required this.dateTime,
    this.meetingLink,
    this.location,
  });
}

final List<AppointmentData> _todayAppointments = const [
  AppointmentData(
    initials: 'JP',
    avatarColor: Color(0xFF3B82F6),
    patientName: 'Juan Pérez',
    modality: 'Virtual',
    isVirtual: true,
    status: 'Confirmada',
    dateTime: 'Hoy, 14:30 PM',
    meetingLink: 'meet.google.com/abc-defg-hij',
  ),
  AppointmentData(
    initials: 'MG',
    avatarColor: Color(0xFF059669),
    patientName: 'Maria García',
    modality: 'Presencial',
    isVirtual: false,
    status: 'Pendiente',
    dateTime: 'Hoy, 16:00 PM',
    location: 'Consultorio 402, Clínica San Felipe',
  ),
];

final List<AppointmentData> _upcomingAppointments = <AppointmentData>[];

final List<AppointmentData> _pastAppointments = const [
  AppointmentData(
    initials: 'RL',
    avatarColor: Color(0xFF94A3B8),
    patientName: 'Ricardo Luna',
    modality: 'Presencial',
    isVirtual: false,
    status: 'Completada',
    dateTime: 'Ayer, 09:00 AM',
    location: 'Consultorio 402, Clínica San Felipe',
  ),
];
