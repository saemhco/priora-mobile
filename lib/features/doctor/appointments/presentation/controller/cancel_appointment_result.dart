import 'package:flutter/foundation.dart';

/// Result of cancelling an appointment.
@immutable
class CancelAppointmentResult {
  const CancelAppointmentResult({required this.success, this.message});

  final bool success;
  final String? message;
}
