import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_cubit.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/controller/places_state.dart';
import 'package:priora/features/doctor/places/data/models/place_model.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_cubit.dart';
import 'package:priora/features/doctor/profile/controller/doctor_profile_state.dart';
import 'package:priora/features/doctor/profile/data/models/doctor_profile_model.dart';
import 'package:priora/features/patient/profile/presentation/widgets/logout_button.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

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

  /// Carga los lugares de atención (GET /places/me). El perfil del
  /// profesional lo carga el DoctorProfileCubit compartido (una sola llamada).
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
              return _buildError();
            }

            final profile = state.profile!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildProfileHeader(profile),
                  const SizedBox(height: 20),
                  _buildEditButton(context),
                  const SizedBox(height: 20),
                  _buildBioSection(profile),
                  const SizedBox(height: 16),
                  _buildContactSection(profile),
                  const SizedBox(height: 16),
                  _buildPlacesSection(),
                  const SizedBox(height: 16),
                  _buildWeeklySummary(profile),
                  const SizedBox(height: 16),
                  _buildProgressCard(profile),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              context.read<DoctorProfileCubit>().state.error ??
                  'Error al cargar el perfil',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<DoctorProfileCubit>().loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0256C2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(DoctorProfileModel profile) {
    final hasPhoto = profile.profilePhotoUrl != null &&
        profile.profilePhotoUrl!.isNotEmpty;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFE2E8F0),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: hasPhoto
                  ? Image.network(
                      profile.profilePhotoUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.primarySpecialty ?? 'Profesional de salud',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0256C2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildTags(profile),
      ],
    );
  }

  Widget _buildTags(DoctorProfileModel profile) {
    final tags = <String>[
      ...profile.professions.map((p) => p.name),
    ];
    if (profile.documentId != null && profile.documentId!.isNotEmpty) {
      final docType = profile.documentType ?? 'DOC';
      tags.add('$docType ${profile.documentId}');
    }
    if (tags.isEmpty) tags.add('Profesional de salud');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(tags.length, (index) {
        final isPrimary = index.isEven;
        return _buildTag(
          tags[index],
          isPrimary
              ? const Color(0xFFE0F7F6)
              : const Color(0xFFF1F5F9),
          isPrimary
              ? const Color(0xFF0C6159)
              : const Color(0xFF64748B),
        );
      }),
    );
  }

  Widget _buildTag(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push(
          '/edit-doctor-profile',
          extra: context.read<DoctorProfileCubit>(),
        ),
        icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF0256C2)),
        label: const Text('Editar Perfil'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0256C2),
          side: const BorderSide(color: Color(0xFF0256C2)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0256C2)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(DoctorProfileModel profile) {
    final bio = profile.bio?.trim() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.description_outlined, 'Biografía'),
          const SizedBox(height: 12),
          Text(
            bio.isEmpty
                ? 'Aún no has añadido una biografía.'
                : bio,
            style: TextStyle(
              color: bio.isEmpty
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(DoctorProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(Icons.contact_page_outlined, 'Contacto'),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.email_outlined,
            'Correo electrónico',
            profile.email.isEmpty ? 'No registrado' : profile.email,
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.phone_outlined,
            'Teléfono',
            (profile.phone == null || profile.phone!.isEmpty)
                ? 'No registrado'
                : profile.phone!,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlacesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            Icons.local_hospital_outlined,
            'Lugares de Atención',
          ),
          const SizedBox(height: 12),
          BlocBuilder<PlacesCubit, PlacesState>(
            builder: (context, state) {
              if (state is PlacesLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0256C2),
                      ),
                    ),
                  ),
                );
              }

              final places = state is PlacesLoaded
                  ? state.places
                  : <PlaceModel>[];
              if (places.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Sin lugares de atención registrados',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return Column(
                children: List.generate(places.length, (index) {
                  final place = places[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == places.length - 1 ? 0 : 8,
                    ),
                    child: _buildPlaceRow(
                      index.isEven
                          ? Icons.medical_services_outlined
                          : Icons.business_outlined,
                      index.isEven
                          ? const Color(0xFF0256C2)
                          : const Color(0xFF059669),
                      place.name,
                      place.locationLabel,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceRow(IconData icon, Color iconColor, String name, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(DoctorProfileModel profile) {
    final rating = profile.rating != null
        ? profile.rating!.toStringAsFixed(1)
        : '—';
    return BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
      builder: (context, state) {
        final allAppointments = [
          ...state.todayAppointments,
          ...state.upcomingAppointments,
          ...state.pastAppointments,
        ];
        final totalAppointments = allAppointments.length;
        final totalPatients = allAppointments
            .map((a) => a.patient.id)
            .where((id) => id.isNotEmpty)
            .toSet()
            .length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0256C2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetric('$totalAppointments', 'Citas'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetric('$totalPatients', 'Pacientes'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetric(rating, 'Rating')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetric(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return LogoutButton(
      onLogout: () {
        context.read<AuthBloc>().add(const AuthLogoutRequested());
        context.go('/login');
      },
    );
  }

  Widget _buildProgressCard(DoctorProfileModel profile) {
    final percent = profile.completionPercent;
    final nextStep = _nextStep(profile);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completar Perfil Profesional',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% Completado',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (nextStep != null)
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Siguiente: $nextStep',
                    style: const TextStyle(
                      color: Color(0xFF0256C2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00CBB8)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String? _nextStep(DoctorProfileModel profile) {
    if (profile.bio == null || profile.bio!.trim().isEmpty) return 'Añadir Bio';
    if (profile.profilePhotoUrl == null || profile.profilePhotoUrl!.isEmpty) {
      return 'Añadir Foto';
    }
    if (profile.phone == null || profile.phone!.trim().isEmpty) {
      return 'Añadir Teléfono';
    }
    if (profile.specialties.isEmpty) return 'Completar Especialidades';
    return null;
  }
}
