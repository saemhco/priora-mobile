import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/presentation/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_bio_section.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_contact_section.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_edit_button.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_error.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_header.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_logout_button.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_places_section.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_progress_card.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_weekly_summary.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Profile screen of the professional. It only composes the widget tree; the
/// state and logic live in [DoctorProfileCubit].
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  /// Charge the service places (GET /places/me). The profile of the
  /// professional is uploaded by the shared DoctorProfileCubit (single call).
  void _loadPlaces() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PlacesCubit>().loadPlaces(
            accessToken: authState.accessToken,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0256C2)),
              );
            }
            if (state.error != null || state.profile == null) {
              return const DoctorProfileError();
            }

            final profile = state.profile!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  DoctorProfileHeader(profile: profile),
                  const SizedBox(height: 20),
                  const DoctorProfileEditButton(),
                  const SizedBox(height: 20),
                  DoctorProfileBioSection(profile: profile),
                  const SizedBox(height: 16),
                  DoctorProfileContactSection(profile: profile),
                  const SizedBox(height: 16),
                  const DoctorProfilePlacesSection(),
                  const SizedBox(height: 16),
                  DoctorProfileWeeklySummary(profile: profile),
                  const SizedBox(height: 16),
                  DoctorProfileProgressCard(profile: profile),
                  const SizedBox(height: 24),
                  const DoctorProfileLogoutButton(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
