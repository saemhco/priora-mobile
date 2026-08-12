import 'package:flutter/material.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';

class PlaceCard extends StatelessWidget {

  const PlaceCard({
    required this.place, super.key,
    this.onEdit,
    this.onDelete,
  });
  final Place place;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF0256C2), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_rounded, color: Color(0xFF0256C2), size: 20),
                ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.locationLabel,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
