import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/agenda_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/location_selector_skeleton.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_state.dart';

/// "Filter by" section of the agenda: filter selector (all / virtual / by
/// place) and its selection bottom sheet.
class LocationFilterSection extends StatelessWidget {
  const LocationFilterSection({required this.controller, super.key});

  final AgendaController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<PlacesCubit, PlacesState>(
          builder: (context, state) {
            if (state is PlacesLoading &&
                controller.selectedPlace == null &&
                !controller.isVirtualSelected) {
              return const LocationSelectorSkeleton();
            }

            final places = state is PlacesLoaded ? state.places : <Place>[];

            String label;
            IconData icon;
            String? subtitle;

            if (controller.isVirtualSelected) {
              label = 'Virtual';
              icon = Icons.videocam_rounded;
            } else if (controller.selectedFilterId == null) {
              label = 'Todos';
              icon = Icons.public_rounded;
              subtitle = 'Virtuales y presenciales';
            } else if (controller.selectedPlace != null) {
              label = controller.selectedPlace!.name;
              icon = Icons.local_hospital_rounded;
              subtitle = controller.selectedPlace!.locationLabel;
            } else if (places.isNotEmpty) {
              label = places.first.name;
              icon = Icons.local_hospital_rounded;
              subtitle = places.first.locationLabel;
            } else {
              label = 'Sin lugares registrados';
              icon = Icons.info_outline_rounded;
            }

            return GestureDetector(
              onTap: () => _showFilterPicker(context, places),
              child: _buildSelector(
                label: label,
                subtitle: subtitle,
                icon: icon,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelector({
    required String label,
    String? subtitle,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.location_on_outlined,
            color: const Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  void _showFilterPicker(BuildContext context, List<Place> places) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Filtrar disponibilidad',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // "Todos" option
                ListTile(
                  leading: _optionIcon(
                    icon: Icons.public_rounded,
                    selected: controller.selectedFilterId == null,
                  ),
                  title: const Text(
                    'Todos',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Mostrar bloques virtuales y presenciales',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: controller.selectedFilterId == null
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0256C2),
                          size: 22,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.selectFilterAll();
                  },
                ),
                const Divider(indent: 20, endIndent: 20),
                // Virtual option
                ListTile(
                  leading: _optionIcon(
                    icon: Icons.videocam_rounded,
                    selected: controller.isVirtualSelected,
                  ),
                  title: const Text(
                    'Virtual',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Mostrar solo bloques virtuales',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: controller.isVirtualSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0256C2),
                          size: 22,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.selectFilterVirtual();
                  },
                ),
                // Solo mostrar lugares si hay
                if (places.isNotEmpty) ...[
                  const Divider(indent: 20, endIndent: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Text(
                      'Lugares de atención',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...places.map(
                    (place) => ListTile(
                      leading: _optionIcon(
                        icon: Icons.local_hospital_rounded,
                        selected: controller.selectedPlace?.id == place.id,
                      ),
                      title: Text(
                        place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        place.locationLabel,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: controller.selectedPlace?.id == place.id
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF0256C2),
                              size: 22,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.selectFilterPlace(place);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionIcon({required IconData icon, required bool selected}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0256C2) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: selected ? Colors.white : const Color(0xFF0256C2),
        size: 22,
      ),
    );
  }
}
