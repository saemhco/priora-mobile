import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_theme.dart';
import 'package:priora/features/doctor/navigation/controller/doctor_navigation_controller.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_state.dart';

/// Agenda header: title "Prioress" and avatar of the doctor.
class AgendaHeader extends StatelessWidget {
  const AgendaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Priora',
          style: TextStyle(
            color: MeetingTypeTheme.virtual.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
          builder: (context, state) {
            final photoUrl = state.profile?.profilePhotoUrl;
            final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
            // Al presionar el avatar se navega al tab de Perfil
            return GestureDetector(
              onTap: () => context.read<DoctorNavigationCubit>().changeIndex(3),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : const ColoredBox(
                          color: Color(0xFFE2E8F0),
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
