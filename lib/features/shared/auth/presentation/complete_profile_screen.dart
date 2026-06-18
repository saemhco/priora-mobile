import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/controller/complete_profile_controller.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/shared/auth/presentation/widgets/personal_info_section.dart';
import 'package:priora/features/shared/auth/presentation/widgets/demographics_section.dart';
import 'package:priora/features/shared/auth/presentation/widgets/location_section.dart';
import 'package:priora/features/shared/auth/presentation/widgets/submit_profile_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CompleteProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompleteProfileController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthAuthenticated && state.profileComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil completado exitosamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (state.role == 'doctor') {
            context.go('/doctor');
          } else {
            context.go('/patient');
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Text(
                        'Editar Perfil',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Actualiza tu información personal para una atención personalizada.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      PersonalInfoSection(
                        controller: _controller,
                        isLoading: isLoading,
                      ),

                      DemographicsSection(
                        controller: _controller,
                        isLoading: isLoading,
                      ),

                      LocationSection(
                        controller: _controller,
                        isLoading: isLoading,
                      ),

                      SubmitProfileButton(
                        onSubmit: () => _controller.saveProfile(
                          context,
                          _formKey,
                          isLoading,
                        ),
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
