import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/controller/appointments_controller.dart';

class DoctorCard extends StatefulWidget {
  final DoctorModel doctor;
  final Function(String) onSelectSlot;
  final VoidCallback onViewCalendar;

  const DoctorCard({
    required this.doctor,
    required this.onSelectSlot,
    required this.onViewCalendar,
    super.key,
  });

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  bool _isExpanded = false;

  Map<String, List<String>> _groupSlotsByDate(List<String> originalSlots) {
    final Map<String, List<String>> grouped = {};
    final now = DateTime.now();

    for (var s in originalSlots) {
      try {
        final dt = DateTime.parse(s).toLocal();
        // Format date label
        String dateLabel = '';
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          dateLabel = 'Hoy, ${_formatDayMonth(dt)}';
        } else if (dt.day == now.day + 1 &&
            dt.month == now.month &&
            dt.year == now.year) {
          dateLabel = 'Mañana, ${_formatDayMonth(dt)}';
        } else {
          dateLabel = _formatDayMonth(dt);
        }

        final hour = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        final formattedHour = '$hour:$min';

        grouped.putIfAbsent(dateLabel, () => []).add(formattedHour);
      } catch (_) {}
    }
    return grouped;
  }

  String _formatDayMonth(DateTime dt) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final groupedSlots = _groupSlotsByDate(widget.doctor.originalSlots);
    final hasMoreDates = groupedSlots.keys.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.doctor.avatarUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF64748B),
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.doctor.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFF22C55E),
                                size: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.doctor.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.doctor.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            widget.doctor.isVirtual
                                ? Icons.videocam_outlined
                                : Icons.location_on_outlined,
                            color: const Color(0xFF64748B),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.doctor.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            // Date and "Ver calendario"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.doctor.nextDateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasMoreDates)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                      widget.onViewCalendar();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Ver menos' : 'Ver calendario',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0E5FD9),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: const Color(0xFF0E5FD9),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Time Slots Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.doctor.timeSlots.map((slot) {
                final isSelected = slot == widget.doctor.selectedTimeSlot;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => widget.onSelectSlot(slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF67E8F9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Expanded section for other dates
            if (_isExpanded && hasMoreDates) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 12),
              ...groupedSlots.entries.skip(1).map((entry) {
                final dateLabel = entry.key;
                final slotsForDate = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: slotsForDate.map((slot) {
                          final isSelected =
                              slot == widget.doctor.selectedTimeSlot;
                          return GestureDetector(
                            onTap: () => widget.onSelectSlot(slot),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF67E8F9)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
