import 'package:flutter/foundation.dart';

/// Resultado de una reserva de cita.
@immutable
class BookingResult {
  const BookingResult({
    required this.success,
    this.message,
    this.isDuplicateSpecialty = false,
  });

  final bool success;
  final String? message;
  final bool isDuplicateSpecialty;
}
