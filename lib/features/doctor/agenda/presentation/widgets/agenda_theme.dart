import 'package:flutter/material.dart';

/// Colour themes by type of care (virtual / face-to-face).
enum MeetingTypeTheme {
  virtual(
    primary: Color(0xFF0256C2),
    lightBg: Color(0xFFEFF6FF),
    mediumBg: Color(0xFFDBEAFE),
    border: Color(0xFFBFDBFE),
    text: Color(0xFF1E40AF),
    iconColor: Color(0xFF0256C2),
    icon: Icons.videocam_rounded,
    label: 'Virtual',
    badgeText: 'Virtual',
  ),
  inPerson(
    primary: Color(0xFF059669),
    lightBg: Color(0xFFECFDF5),
    mediumBg: Color(0xFFA7F3D0),
    border: Color(0xFF6EE7B7),
    text: Color(0xFF065F46),
    iconColor: Color(0xFF059669),
    icon: Icons.business_rounded,
    label: 'Presencial',
    badgeText: 'Presencial',
  );

  const MeetingTypeTheme({
    required this.primary,
    required this.lightBg,
    required this.mediumBg,
    required this.border,
    required this.text,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.badgeText,
  });

  final Color primary;
  final Color lightBg;
  final Color mediumBg;
  final Color border;
  final Color text;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String badgeText;

  /// Theme according to the type of service; virtual default.
  static MeetingTypeTheme fromType(String? slotType) {
    return slotType == 'IN_PERSON'
        ? MeetingTypeTheme.inPerson
        : MeetingTypeTheme.virtual;
  }
}

/// ID del filtro "solo virtual".
const String kVirtualFilterId = '__virtual__';

/// Short labels of the days of the week (1=Mon ... 7=Sun).
const List<String> kDayLabels = [
  'LUN',
  'MAR',
  'MIÉ',
  'JUE',
  'VIE',
  'SÁB',
  'DOM',
];
