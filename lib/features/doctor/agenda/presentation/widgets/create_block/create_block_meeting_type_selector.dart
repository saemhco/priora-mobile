import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_radio_card.dart';

/// Selector of the type of attention of the block: virtual or face-to-face.
class CreateBlockMeetingTypeSelector extends StatelessWidget {
  const CreateBlockMeetingTypeSelector({
    required this.controller, super.key,
  });

  final CreateBlockController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateBlockRadioCard(
          title: 'Virtual',
          subtitle: 'Teleconsulta / videollamada.',
          value: 'VIRTUAL',
          groupValue: controller.meetingType,
          onChanged: (v) {
            if (v != null) controller.setMeetingType(v);
          },
        ),
        const SizedBox(height: 8),
        CreateBlockRadioCard(
          title: 'Presencial',
          subtitle: 'Atención en consultorio o clínica.',
          value: 'IN_PERSON',
          groupValue: controller.meetingType,
          onChanged: (v) {
            if (v != null) controller.setMeetingType(v);
          },
        ),
      ],
    );
  }
}
