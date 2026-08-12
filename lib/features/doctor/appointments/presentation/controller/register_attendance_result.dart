import 'package:flutter/foundation.dart';

/// Result of the care record of an appointment.
@immutable
class RegisterAttendanceResult {
  const RegisterAttendanceResult({required this.success, this.message});

  final bool success;
  final String? message;
}
