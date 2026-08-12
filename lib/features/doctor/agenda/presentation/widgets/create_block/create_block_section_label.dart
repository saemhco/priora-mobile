import 'package:flutter/material.dart';

/// Section label of the "Create Block" form.
class CreateBlockSectionLabel extends StatelessWidget {
  const CreateBlockSectionLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
