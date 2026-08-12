import 'package:flutter/material.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';

/// Paleta de colores para los avatares de pacientes.
const List<Color> kAvatarPalette = [
  Color(0xFF3B82F6),
  Color(0xFF059669),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF06B6D4),
];

/// Deterministic color of the avatar based on the patient's name.
Color avatarColorFor(String name) {
  var hash = 0;
  for (final code in name.codeUnits) {
    hash = (hash + code) % 997;
  }
  return kAvatarPalette[hash % kAvatarPalette.length];
}

/// Formatea la fecha/hora de una cita: "Hoy, HH:mm" o "d MMM, HH:mm".
String formatAppointmentDateTime(DoctorAppointment appointment) {
  if (appointment.isToday) {
    return 'Hoy, ${appointment.formattedTime}';
  }
  return '${appointment.formattedDate}, ${appointment.formattedTime}';
}
