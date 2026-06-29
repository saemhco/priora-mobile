import 'package:flutter/material.dart';
import 'package:priora/features/patient/profile/controller/patient_profile_controller.dart';
import 'package:priora/features/patient/profile/presentation/widgets/profile_header_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/personal_info_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/location_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/logout_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_cubit.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_state.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = context.read<AuthBloc>().state;
    final token = authState is AuthAuthenticated ? authState.accessToken : '';
    context.read<ProfileCubit>().loadProfile(accessToken: token);
  }

  @override
  Widget build(BuildContext context) {
    final controller = PatientProfileController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: const Color(0xFF0256C2),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const ProfileSkeleton();
              } else if (state is ProfileError) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
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
              } else {
                // ProfileLoaded, ProfileUpdating, ProfileUpdated
                final profileModel = (state is ProfileLoaded)
                    ? state.profile
                    : (state is ProfileUpdating)
                    ? state.currentProfile
                    : (state is ProfileUpdated)
                    ? state.updatedProfile
                    : null;
                final profileMap = profileModel?.toJson();

                return Column(
                  children: [
                    // Top Profile Card
                    ProfileHeaderCard(
                      profile: profileMap,
                      onEdit: () async {
                        controller.editProfile(context);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Personal Info Card
                    PersonalInfoCard(profile: profileMap),
                    const SizedBox(height: 20),

                    // Location Card
                    LocationCard(profile: profileMap),
                    const SizedBox(height: 20),

                    // Logout Button
                    LogoutButton(onLogout: () => controller.logout(context)),
                    const SizedBox(height: 20),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: Column(
        children: [
          // Header Card Skeleton
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          // Info Card Skeleton
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          // Location Card Skeleton
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
