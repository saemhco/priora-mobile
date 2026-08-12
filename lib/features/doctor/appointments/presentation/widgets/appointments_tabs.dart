import 'package:flutter/material.dart';

/// Appointment screen tabs: Today / Upcoming / Past.
class AppointmentsTabs extends StatelessWidget {
  const AppointmentsTabs({super.key});

  @override
  Widget build(BuildContext context) {
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
}
