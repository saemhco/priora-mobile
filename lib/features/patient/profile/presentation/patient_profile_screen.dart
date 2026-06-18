import 'package:flutter/material.dart';
import 'package:priora/features/patient/profile/controller/patient_profile_controller.dart';
import 'package:priora/features/patient/profile/presentation/widgets/profile_header_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/personal_info_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/location_card.dart';
import 'package:priora/features/patient/profile/presentation/widgets/status_badges_row.dart';
import 'package:priora/features/patient/profile/presentation/widgets/logout_button.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PatientProfileController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // Top Profile Card
            ProfileHeaderCard(
              onEdit: () => controller.editProfile(context),
            ),
            const SizedBox(height: 20),

            // Personal Info Card
            const PersonalInfoCard(),
            const SizedBox(height: 20),

            // Location Card
            const LocationCard(),
            const SizedBox(height: 20),

            // Status Badges Row
            const StatusBadgesRow(),
            const SizedBox(height: 24),

            // Logout Button
            LogoutButton(
              onLogout: () => controller.logout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
