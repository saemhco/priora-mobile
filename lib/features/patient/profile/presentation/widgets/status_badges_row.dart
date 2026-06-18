import 'package:flutter/material.dart';

class StatusBadgesRow extends StatelessWidget {
  const StatusBadgesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Insurance card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7F6),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.business_center_rounded,
                  color: Color(0xFF00CBB8),
                  size: 26,
                ),
                SizedBox(height: 12),
                Text(
                  'Seguro\nPremium',
                  style: TextStyle(
                    color: Color(0xFF0C6159),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'RIMAC Seguros',
                  style: TextStyle(
                    color: Color(0xFF00CBB8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Verification card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6E8),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF85A047),
                  size: 26,
                ),
                SizedBox(height: 12),
                Text(
                  'Estado',
                  style: TextStyle(
                    color: Color(0xFF4D611E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cuenta Verificada',
                  style: TextStyle(
                    color: Color(0xFF85A047),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
