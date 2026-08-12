import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';

/// Button to navigate to the profile edit.
class DoctorProfileEditButton extends StatelessWidget {
  const DoctorProfileEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push(
          '/edit-doctor-profile',
          extra: context.read<DoctorProfileCubit>(),
        ),
        icon: const Icon(
          Icons.edit_rounded,
          size: 18,
          color: Color(0xFF0256C2),
        ),
        label: const Text('Editar Perfil'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0256C2),
          side: const BorderSide(color: Color(0xFF0256C2)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
