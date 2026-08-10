import 'package:flutter/material.dart';
import 'package:priora/features/patient/navigation/controller/patient_navigation_controller.dart';
import 'package:priora/features/patient/triage/presentation/controller/triage_state.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_result_view.dart';

class TriageResultScreen extends StatelessWidget {

  const TriageResultScreen({
    required this.state, required this.navigationCubit, super.key,
  });
  final TriageState state;
  final PatientNavigationCubit navigationCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resultado de Triaje',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: TriageResultView(state: state, navigationCubit: navigationCubit),
    );
  }
}
