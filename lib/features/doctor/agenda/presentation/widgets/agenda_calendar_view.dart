import 'package:flutter/material.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/agenda_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_calendar_skeleton.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/agenda_theme.dart';

/// Weekly doctor availability calendar: header of days, rows of hours and
/// slot cells (virtual / face-to-face).
class AgendaCalendarView extends StatelessWidget {
  const AgendaCalendarView({required this.controller, super.key});

  final AgendaController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingBlocks && controller.hours.isEmpty) {
      return const AgendaCalendarSkeleton();
    }

    if (controller.hours.isEmpty && !controller.isLoadingBlocks) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            ...List.generate(controller.hours.length, _buildTimeRow),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isVirtual = controller.isVirtualSelected;
    final place = controller.selectedPlace;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              isVirtual
                  ? Icons.videocam_rounded
                  : place != null
                  ? Icons.business_rounded
                  : Icons.event_busy_rounded,
              size: 48,
              color: const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              isVirtual
                  ? 'Sin bloques virtuales'
                  : place != null
                  ? 'Sin bloques en este lugar'
                  : 'Sin bloques de disponibilidad',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crea tu primer bloque con el botón "Crear bloque"',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 60),
        ...List.generate(kDayLabels.length, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          return Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
              color: isToday
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8FAFC),
            ),
            child: Text(
              kDayLabels[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isToday
                    ? const Color(0xFF0256C2)
                    : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeRow(int rowIndex) {
    if (controller.hours.isEmpty) return const SizedBox.shrink();
    final time = controller.hours[rowIndex];
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            time,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...List.generate(kDayLabels.length, (colIndex) {
          final key = '${colIndex}_$rowIndex';
          final isAvailable = controller.availableSlots.contains(key);
          final slotType = controller.slotTypes[key];
          return _buildSlotCell(isAvailable, slotType);
        }),
      ],
    );
  }

  Widget _buildSlotCell(bool isAvailable, String? slotType) {
    final theme = MeetingTypeTheme.fromType(slotType);
    final isVirtual = slotType == 'VIRTUAL' || slotType == null;

    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF1F5F9), width: 0.5),
        color: isAvailable ? theme.lightBg : const Color(0xFFF8FAFC),
      ),
      child: isAvailable
          ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: theme.primary, width: 3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVirtual ? Icons.videocam_rounded : Icons.business_rounded,
                    size: 14,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVirtual ? 'Virtual' : 'Presencial',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
