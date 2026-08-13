import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_state.dart';

/// Place of care selector for face-to-face blocks.
class CreateBlockLocationSelector extends StatelessWidget {
  const CreateBlockLocationSelector({
    required this.controller,
    super.key,
  });

  final CreateBlockController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesCubit, PlacesState>(
      builder: (context, state) {
        var places = <Place>[];
        if (state is PlacesLoaded) {
          places = state.places;
        }

        if (places.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No tienes lugares registrados. Crea uno en "Lugares de Atención".',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: places.map((place) {
            final selected = controller.selectedPlace?.id == place.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => controller.setSelectedPlace(place),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF0256C2)
                          : const Color(0xFFE2E8F0),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF0256C2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF0256C2),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            if (place.address != null ||
                                place.locationLabel.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  place.address ?? place.locationLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: place.id,
                        groupValue: controller.selectedPlace?.id,
                        onChanged: (v) {
                          if (v != null) {
                            controller.setSelectedPlace(place);
                          }
                        },
                        activeColor: const Color(0xFF0256C2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
