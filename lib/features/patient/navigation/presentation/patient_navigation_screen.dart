import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/presentation/appointments_screen.dart';
import 'package:priora/features/patient/home/presentation/patient_home_screen.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/navigation/presentation/widgets/patient_nav_item.dart';
import 'package:priora/features/patient/navigation/presentation/widgets/placeholder_tab.dart';
import 'package:priora/features/patient/profile/presentation/patient_profile_screen.dart';

class PatientNavigationScreen extends StatefulWidget {
  const PatientNavigationScreen({super.key});

  @override
  State<PatientNavigationScreen> createState() => _PatientNavigationScreenState();
}

class _PatientNavigationScreenState extends State<PatientNavigationScreen> {
  final PatientNavigationController _controller = PatientNavigationController();

  final List<Widget> _tabs = [
    const PatientHomeScreen(),
    const PlaceholderTab(title: 'Evaluación IA', icon: Icons.psychology_outlined),
    const PatientAppointmentsScreen(),
    const PatientProfileScreen(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            bottom: false,
            child: _tabs[_controller.currentIndex],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Inicio'),
              _buildNavItem(1, Icons.assignment_outlined, 'Evaluación IA'),
              _buildNavItem(2, Icons.calendar_today_outlined, 'Mis citas'),
              _buildNavItem(3, Icons.person_outline_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return PatientNavItem(
      index: index,
      icon: icon,
      label: label,
      isSelected: _controller.currentIndex == index,
      onTap: () => _controller.changeIndex(index),
    );
  }
}
