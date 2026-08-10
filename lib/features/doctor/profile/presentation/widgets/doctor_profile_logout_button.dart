import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/patient/profile/presentation/widgets/logout_button.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_event.dart';

/// Log out button of the professional's profile.
class DoctorProfileLogoutButton extends StatelessWidget {
  const DoctorProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LogoutButton(
      onLogout: () {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go('/login');
      },
    );
  }
}
