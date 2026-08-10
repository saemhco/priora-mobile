import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/agenda_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/delete_block_sheet.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/delete_block_sheet_result.dart';

/// Agenda action buttons: “Create Block” and “Delete”.
class AgendaActionButtons extends StatelessWidget {
  const AgendaActionButtons({required this.controller, super.key});

  final AgendaController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push<bool>('/create-block');
              if (result == true) {
                controller.loadData();
              }
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Crear bloque'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0256C2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openDeleteBlockSheet(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text('Eliminar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDeleteBlockSheet(BuildContext context) async {
    if (controller.schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay bloques para eliminar'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<DeleteBlockSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DeleteBlockSheet(blocks: controller.schedules),
    );

    if (result == null || !result.success || result.blockId == null) return;
    if (!context.mounted) return;

    final deleteResult = await controller.deleteBlock(result.blockId!);
    if (!context.mounted) return;

    if (deleteResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bloque eliminado correctamente'),
          backgroundColor: Color(0xFF475569),
        ),
      );
      await controller.loadBlocks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleteResult.message ?? 'Error al eliminar el bloque',
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
