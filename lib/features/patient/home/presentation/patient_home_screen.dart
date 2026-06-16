import 'package:flutter/material.dart';
import 'package:priora/features/patient/home/presentation/widgets/home_header.dart';
import 'package:priora/features/patient/home/presentation/widgets/next_appointment_card.dart';
import 'package:priora/features/patient/home/presentation/widgets/ai_evaluation_card.dart';
import 'package:priora/features/patient/home/presentation/widgets/quick_access_section.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Top Header
          HomeHeader(),
          SizedBox(height: 24),

          // Welcome message
          Text(
            'Hola, Juan',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tu salud está en buenas manos hoy.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'ORIENTA  •  PRIORIZA  •  CONECTA',
            style: TextStyle(
              color: Color(0xFF0256C2),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          SizedBox(height: 24),

          // Próxima Cita Card
          NextAppointmentCard(),
          SizedBox(height: 24),

          // AI Evaluation Card
          AIEvaluationCard(),
          SizedBox(height: 28),

          // Quick Access Section
          QuickAccessSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
