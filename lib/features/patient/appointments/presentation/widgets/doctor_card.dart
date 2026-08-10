import 'package:flutter/material.dart';
import 'package:priora/features/patient/appointments/domain/models/doctor.dart';

class DoctorCard extends StatefulWidget {
  const DoctorCard({
    required this.doctor,
    required this.onSelectSlot,
    required this.onViewCalendar,
    super.key,
  });
  final Doctor doctor;
  final void Function(String) onSelectSlot;
  final VoidCallback onViewCalendar;

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  bool _isExpanded = false;

  Map<String, List<String>> _groupSlotsByDate(
    List<Map<String, dynamic>> rawSlots,
  ) {
    final grouped = <String, List<String>>{};
    final now = DateTime.now();

    for (final slot in rawSlots) {
      try {
        final startTime = slot['startTime']?.toString();
        if (startTime == null || startTime.isEmpty) continue;
        // Preferir el campo date tal como lo envía el backend
        final dateStr = slot['date']?.toString();
        final dt = dateStr != null && dateStr.isNotEmpty
            ? DateTime.parse(dateStr)
            : DateTime.parse(slot['datetime'].toString()).toLocal();

        // Format date label
        var dateLabel = '';
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          dateLabel = 'Hoy, ${_formatDayMonth(dt)}';
        } else if (dt.day == now.day + 1 &&
            dt.month == now.month &&
            dt.year == now.year) {
          dateLabel = 'Mañana, ${_formatDayMonth(dt)}';
        } else {
          dateLabel = _formatDayMonth(dt);
        }

        grouped.putIfAbsent(dateLabel, () => []).add(startTime);
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

  /// Time chip that also shows the type of appointment (Virtual /
  /// Face-to-face).
  Widget _buildSlotChip({
    required String slot,
    required bool isSelected,
    required String? meetingType,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    final isVirtual = meetingType == 'VIRTUAL';
    final hasType = meetingType != null;
    final typeColor = isVirtual
        ? const Color(0xFF0256C2)
        : const Color(0xFF059669);
    final typeIcon = isVirtual
        ? Icons.videocam_rounded
        : Icons.business_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(vertical: 8, horizontal: 4)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF67E8F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: compact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF334155),
                    ),
                  ),
                  if (hasType) ...[
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 9, color: typeColor),
                          const SizedBox(width: 2),
                          Text(
                            isVirtual ? 'Virtual' : 'Presencial',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF334155),
                    ),
                  ),
                  if (hasType) ...[
                    const SizedBox(width: 6),
                    Icon(typeIcon, size: 12, color: typeColor),
                    const SizedBox(width: 3),
                    Text(
                      isVirtual ? 'Virtual' : 'Presencial',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedSlots = _groupSlotsByDate(widget.doctor.rawSlots);
    final hasMoreDates = groupedSlots.keys.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                final meetingType = widget.doctor.meetingTypeForSlot(slot);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildSlotChip(
                      slot: slot,
                      isSelected: isSelected,
                      meetingType: meetingType,
                      compact: true,
                      onTap: () => widget.onSelectSlot(slot),
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
                  padding: const EdgeInsets.only(bottom: 12),
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
                          final meetingType = widget.doctor.meetingTypeForSlot(
                            slot,
                          );
                          return _buildSlotChip(
                            slot: slot,
                            isSelected: isSelected,
                            meetingType: meetingType,
                            onTap: () => widget.onSelectSlot(slot),
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
