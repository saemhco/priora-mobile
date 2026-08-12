import 'package:flutter/foundation.dart';

/// Result of updating the professional's profile.
@immutable
class DoctorProfileUpdateResult {
  const DoctorProfileUpdateResult({required this.success, this.message});

  final bool success;
  final String? message;
}
