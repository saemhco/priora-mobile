import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_event.dart';

/// Controller de acciones de la pantalla de perfil del paciente.
class PatientProfileController {
  void logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.go('/login');
  }

  void editProfile(BuildContext context) {
    context.push('/edit-profile');
  }
}
