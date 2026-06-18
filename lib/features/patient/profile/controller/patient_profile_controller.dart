import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';

class PatientProfileController {
  void logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.go('/login');
  }

  void editProfile(BuildContext context) {
    // Handle future edit profile page route or action
  }
}
