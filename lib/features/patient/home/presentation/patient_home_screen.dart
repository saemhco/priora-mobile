import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/patient/home/presentation/widgets/home_header.dart';
import 'package:priora/features/patient/home/presentation/widgets/next_appointment_card.dart';
import 'package:priora/features/patient/home/presentation/widgets/ai_evaluation_card.dart';
import 'package:priora/features/patient/home/presentation/widgets/quick_access_section.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch Load Profile Event to get name/photo from API
    context.read<AuthBloc>().add(const AuthLoadProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Top Header
          const HomeHeader(),
          const SizedBox(height: 24),

          // Welcome message
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = 'Paciente';
              if (state is AuthAuthenticated && state.firstName != null && state.firstName!.isNotEmpty) {
                name = state.firstName!;
              }
              return Text(
                'Hola, $name',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text(
            'Tu salud está en buenas manos hoy.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'ORIENTA  •  PRIORIZA  •  CONECTA',
            style: TextStyle(
              color: Color(0xFF0256C2),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // Próxima Cita Card
          const NextAppointmentCard(),
          const SizedBox(height: 24),

          // AI Evaluation Card
          const AIEvaluationCard(),
          const SizedBox(height: 28),

          // Quick Access Section
          const QuickAccessSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
