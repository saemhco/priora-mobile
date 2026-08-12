import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_radio_card.dart';

/// Selector de vigencia del formulario de bloque: ilimitada o rango de fechas.
class CreateBlockValiditySelector extends StatelessWidget {
  const CreateBlockValiditySelector({
    required this.controller,
    super.key,
  });

  final CreateBlockController controller;

  Future<void> _pickDate(
    BuildContext context, {
    required bool isFrom,
  }) async {
    final now = DateTime.now();
    final current = isFrom ? controller.validFrom : controller.validTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('es'),
    );
    if (picked == null) return;
    final formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    if (isFrom) {
      controller.setValidFrom(picked, formatted: formatted);
    } else {
      controller.setValidTo(picked, formatted: formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateBlockRadioCard(
          title: 'Ilimitada',
          subtitle: 'Sin fecha de término. Válido siempre.',
          value: 'unlimited',
          groupValue: controller.validity,
          onChanged: (v) {
            if (v != null) controller.setValidity(v);
          },
        ),
        const SizedBox(height: 8),
        CreateBlockRadioCard(
          title: 'Rango',
          subtitle: 'Define una fecha de inicio y fin.',
          value: 'range',
          groupValue: controller.validity,
          onChanged: (v) {
            if (v != null) controller.setValidity(v);
          },
        ),
        if (controller.validity == 'range') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Desde',
                  controller: controller.fromController,
                  onTap: () => _pickDate(context, isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Hasta',
                  controller: controller.toController,
                  onTap: () => _pickDate(context, isFrom: false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF64748B),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
