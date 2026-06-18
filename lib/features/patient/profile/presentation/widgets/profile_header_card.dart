import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class ProfileHeaderCard extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileHeaderCard({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String fullName = 'Paciente';
        String? photoUrl;

        if (state is AuthAuthenticated) {
          final first = state.firstName ?? '';
          final last = state.lastName ?? '';
          fullName = '$first $last'.trim();
          if (fullName.isEmpty) fullName = 'Paciente';
          photoUrl = state.profilePhotoUrl;
        }

        final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 40, color: Color(0xFF64748B)),
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Name and Subtitle
              Text(
                fullName,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Paciente Asegurado',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          const SizedBox(height: 20),

          // Edit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
              label: const Text(
                'Editar perfil',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  },
);
  }
}
