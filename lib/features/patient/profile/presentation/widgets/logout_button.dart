import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({required this.onLogout, super.key});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
          color: Color(0xFF64748B),
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
