import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_step1_form.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_step2_chat.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_step3_analysis.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_result_view.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class TriageScreen extends StatelessWidget {
  final Map<String, dynamic>? initialDraft;

  const TriageScreen({super.key, this.initialDraft});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TriageCubit>(
      create: (context) {
        final cubit = TriageCubit(
          triageRepository: RepositoryProvider.of<TriageRepository>(context),
        );
        if (initialDraft != null) {
          cubit.loadDraft(initialDraft!);
        }
        return cubit;
      },
      child: const _TriageScreenBody(),
    );
  }
}

class _TriageScreenBody extends StatefulWidget {
  const _TriageScreenBody();

  @override
  State<_TriageScreenBody> createState() => _TriageScreenBodyState();
}

class _TriageScreenBodyState extends State<_TriageScreenBody> {
  late final TriageCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<TriageCubit>();
  }

  void _showExitConfirmation(BuildContext context, TriageCubit cubit) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                '¿Abandonar triaje?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: const Text(
            'Si sales ahora, se borrará todo el progreso actual de tu evaluación de síntomas.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Abandonar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState is AuthAuthenticated ? authState.accessToken : '';

    return BlocConsumer<TriageCubit, TriageState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
              onPressed: () {
                if (state.isCompleted || state.currentStep == 4) {
                  Navigator.of(context).pop();
                } else {
                  _showExitConfirmation(context, _cubit);
                }
              },
            ),
            title: const Text(
              'Priora',
              style: TextStyle(
                color: Color(0xFF0256C2),
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
          body: SafeArea(
            child: _buildBody(state, accessToken),
          ),
        );
      },
    );
  }

  Widget _buildBody(TriageState state, String accessToken) {
    if (state.currentStep == 1) {
      return TriageStep1Form(accessToken: accessToken, state: state);
    } else if (state.currentStep == 2) {
      return TriageStep2Chat(accessToken: accessToken, state: state);
    } else if (state.currentStep == 3) {
      return TriageStep3Analysis(state: state);
    } else {
      return TriageResultView(state: state);
    }
  }
}
