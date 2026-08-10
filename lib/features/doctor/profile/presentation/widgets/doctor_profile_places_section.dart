import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_state.dart';
import 'package:priora/features/doctor/profile/presentation/widgets/doctor_profile_section_header.dart';

/// Places of care section of the professional's profile.
class DoctorProfilePlacesSection extends StatelessWidget {
  const DoctorProfilePlacesSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          const DoctorProfileSectionHeader(
            icon: Icons.local_hospital_outlined,
            title: 'Lugares de Atención',
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
                  : <Place>[];
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

  Widget _buildPlaceRow(
    IconData icon,
    Color iconColor,
    String name,
    String subtitle,
  ) {
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
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8),
            size: 22,
          ),
        ],
      ),
    );
  }
}
