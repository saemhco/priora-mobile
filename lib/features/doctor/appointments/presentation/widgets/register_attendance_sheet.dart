import 'package:flutter/material.dart';
import 'package:priora/features/doctor/appointments/domain/models/doctor_appointment.dart';
import 'package:priora/features/doctor/appointments/presentation/controller/register_attendance_result.dart';
import 'package:priora/features/doctor/appointments/presentation/widgets/appointments_theme.dart';

/// Bottom sheet to record the attention of an appointment.
class RegisterAttendanceSheet extends StatefulWidget {
  const RegisterAttendanceSheet({
    required this.appointment,
    required this.onRegister,
    super.key,
  });

  final DoctorAppointment appointment;
  final Future<RegisterAttendanceResult> Function(String note) onRegister;

  @override
  State<RegisterAttendanceSheet> createState() =>
      _RegisterAttendanceSheetState();
}

class _RegisterAttendanceSheetState extends State<RegisterAttendanceSheet> {
  static const int _minChars = 10;

  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  String get _note => _noteController.text.trim();

  bool get _isValid => _note.length >= _minChars;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await widget.onRegister(_note);
    if (!mounted) return;

    if (result.success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            result.message ??
            'Error al registrar la atención. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isVirtual = appointment.isVirtual;
    final avatarColor = avatarColorFor(appointment.patient.fullName);
    final noteColor = _note.isEmpty
        ? const Color(0xFF94A3B8)
        : _isValid
        ? const Color(0xFF059669)
        : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Registrar atención',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Confirma que la cita fue atendida y añade una nota de evidencia.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            // Resumen de la cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      appointment.patient.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patient.fullName,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isVirtual ? 'Virtual' : 'Presencial'} · '
                          '${formatAppointmentDateTime(appointment)}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.statusLabel,
                      style: const TextStyle(
                        color: Color(0xFF0256C2),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nota de atención
            TextField(
              controller: _noteController,
              maxLines: 5,
              minLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nota de atención',
                alignLabelWithHint: true,
                hintText: 'Describe brevemente cómo se realizó la atención…',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0256C2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${_note.length} caracteres',
                  style: TextStyle(
                    color: noteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_note.isNotEmpty && !_isValid) ...[
                  const SizedBox(width: 8),
                  const Text(
                    '· mínimo 10 caracteres',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isValid && !_isSubmitting ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Registrando…' : 'Confirmar atención',
                ),
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
                  disabledBackgroundColor: const Color(0xFFBFDBFE),
                  disabledForegroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
