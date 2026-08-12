import 'package:flutter/material.dart';

/// Indicador de carga de la pantalla de citas.
class AppointmentsLoading extends StatelessWidget {
  const AppointmentsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0256C2)),
    );
  }
}
