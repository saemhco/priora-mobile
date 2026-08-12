import 'package:flutter/material.dart';

/// Agenda information banner: warns that slots will be visible to patients
/// when booking.
class AgendaInfoBanner extends StatelessWidget {
  const AgendaInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF059669), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'El paciente verá estos slots al reservar',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
