import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/patient/profile/presentation/controller/patient_profile_controller.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_cubit.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_state.dart';
import 'package:priora/features/patient/profile/presentation/widgets/location_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/logout_button.dart';
import 'package:priora/features/patient/profile/presentation/widgets/personal_info_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/profile_header_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/profile_skeleton.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Patient profile screen. It only composes the widget tree; the state and
/// logic live in [ProfileCubit].
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _controller = PatientProfileController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = context.read<AuthBloc>().state;
    final token = authState is AuthAuthenticated ? authState.accessToken : '';
    await context.read<ProfileCubit>().loadProfile(accessToken: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: const Color(0xFF0256C2),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const ProfileSkeleton();
              } else if (state is ProfileError) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0256C2),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // ProfileLoaded, ProfileUpdating, ProfileUpdated
              final profile = (state is ProfileLoaded)
                  ? state.profile
                  : (state is ProfileUpdating)
                  ? state.currentProfile
                  : (state is ProfileUpdated)
                  ? state.updatedProfile
                  : null;

              return Column(
                children: [
                  // Top Profile Card
                  ProfileHeaderCard(
                    profile: profile,
                    onEdit: () => _controller.editProfile(context),
                  ),
                  const SizedBox(height: 20),

                  // Personal Info Card
                  PersonalInfoCard(profile: profile),
                  const SizedBox(height: 20),

                  // Location Card
                  LocationCard(profile: profile),
                  const SizedBox(height: 20),

                  // Logout Button
                  LogoutButton(onLogout: () => _controller.logout(context)),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
