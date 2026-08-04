import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/agenda/data/availability_service.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/controller/places_state.dart';
import 'package:priora/features/doctor/places/data/models/place_model.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class CreateBlockScreen extends StatefulWidget {
  const CreateBlockScreen({super.key});

  @override
  State<CreateBlockScreen> createState() => _CreateBlockScreenState();
}

class _CreateBlockScreenState extends State<CreateBlockScreen> {
  // Days of week: 1=Mon ... 7=Sun
  static const List<Map<String, dynamic>> _days = [
    {'label': 'Lun', 'value': 1},
    {'label': 'Mar', 'value': 2},
    {'label': 'Mié', 'value': 3},
    {'label': 'Jue', 'value': 4},
    {'label': 'Vie', 'value': 5},
    {'label': 'Sáb', 'value': 6},
    {'label': 'Dom', 'value': 7},
  ];

  final Set<int> _selectedDays = {};
  final List<String> _timeSlots = [];
  String? _pendingTime;

  String _validity = 'unlimited'; // 'unlimited' | 'range'
  DateTime? _validFrom;
  DateTime? _validTo;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  String _meetingType = 'VIRTUAL'; // 'VIRTUAL' | 'IN_PERSON'
  PlaceModel? _selectedPlace;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      getIt<PlacesCubit>().loadPlaces(accessToken: authState.accessToken);
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool isFrom,
    required DateTime? current,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        final formatted =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        if (isFrom) {
          _validFrom = picked;
          _fromController.text = formatted;
        } else {
          _validTo = picked;
          _toController.text = formatted;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final normalized =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (_timeSlots.contains(normalized)) {
        _showError('Esta hora ya fue agregada');
        return;
      }
      setState(() => _pendingTime = normalized);
    }
  }

  void _confirmPendingTime() {
    if (_pendingTime == null) return;
    setState(() {
      _timeSlots.add(_pendingTime!);
      _pendingTime = null;
    });
  }

  void _removeTimeSlot(String time) {
    setState(() => _timeSlots.remove(time));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  Future<void> _handleSave() async {
    if (_selectedDays.isEmpty) {
      _showError('Selecciona al menos un día');
      return;
    }
    if (_timeSlots.isEmpty) {
      _showError('Agrega al menos un horario');
      return;
    }
    if (_validity == 'range') {
      if (_validFrom == null || _validTo == null) {
        _showError('Completa las fechas de vigencia');
        return;
      }
      if (_validTo!.isBefore(_validFrom!)) {
        _showError('La fecha fin debe ser posterior a la fecha inicio');
        return;
      }
    }
    if (_meetingType == 'IN_PERSON' && _selectedPlace == null) {
      _showError('Selecciona un lugar de atención presencial');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final service = getIt<AvailabilityService>();
      final data = <String, dynamic>{
        'daysOfWeek': _selectedDays.toList()..sort(),
        'timeSlots': _timeSlots,
        'validity': _validity,
        'meetingType': _meetingType,
      };

      if (_validity == 'range') {
        data['validFrom'] = _fromController.text;
        data['validTo'] = _toController.text;
      }

      if (_meetingType == 'IN_PERSON' && _selectedPlace != null) {
        data['placeId'] = _selectedPlace!.id;
      }

      await service.createWeekly(
        accessToken: authState.accessToken,
        data: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bloque creado exitosamente'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlacesCubit>.value(
      value: getIt<PlacesCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B), size: 24),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Bloque de disponibilidad',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                const Text(
                  'Define cuándo estarás disponible para citas.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Days of week
                _buildSectionLabel('DÍAS DE LA SEMANA'),
                const SizedBox(height: 10),
                _buildDaysSelector(),
                const SizedBox(height: 6),
                const Text(
                  'Se repite cada semana en los días seleccionados.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Validity
                _buildSectionLabel('VIGENCIA'),
                const SizedBox(height: 10),
                _buildValiditySelector(),
                const SizedBox(height: 24),

                // Time slots
                _buildSectionLabel('HORARIOS'),
                const SizedBox(height: 10),
                _buildTimeSlotsInput(),
                const SizedBox(height: 24),

                // Meeting type
                _buildSectionLabel('TIPO DE ATENCIÓN'),
                const SizedBox(height: 10),
                _buildMeetingTypeSelector(),
                const SizedBox(height: 24),

                // Location (only for IN_PERSON)
                if (_meetingType == 'IN_PERSON') ...[
                  _buildSectionLabel('LUGAR DE ATENCIÓN'),
                  const SizedBox(height: 10),
                  _buildLocationSelector(),
                  const SizedBox(height: 24),
                ],

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0256C2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar bloque'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
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

  Widget _buildDaysSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _days.map((day) {
        final value = day['value'] as int;
        final label = day['label'] as String;
        final selected = _selectedDays.contains(value);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedDays.remove(value);
              } else {
                _selectedDays.add(value);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF0256C2) : const Color(0xFFE2E8F0),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF0256C2) : const Color(0xFF64748B),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValiditySelector() {
    return Column(
      children: [
        _buildRadioCard(
          title: 'Ilimitada',
          subtitle: 'Sin fecha de término. Válido siempre.',
          value: 'unlimited',
          groupValue: _validity,
          onChanged: (v) {
            if (v != null) setState(() => _validity = v);
          },
        ),
        const SizedBox(height: 8),
        _buildRadioCard(
          title: 'Rango',
          subtitle: 'Define una fecha de inicio y fin.',
          value: 'range',
          groupValue: _validity,
          onChanged: (v) {
            if (v != null) setState(() => _validity = v);
          },
        ),
        if (_validity == 'range') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Desde',
                  controller: _fromController,
                  onTap: () => _pickDate(isFrom: true, current: _validFrom),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Hasta',
                  controller: _toController,
                  onTap: () => _pickDate(isFrom: false, current: _validTo),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRadioCard({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0256C2) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value, 
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: onChanged,
              activeColor: const Color(0xFF0256C2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Added time slots chips
        if (_timeSlots.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((time) {
              return Chip(
                label: Text(
                  _formatTimeDisplay(time),
                  style: const TextStyle(
                    color: Color(0xFF0256C2),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                onDeleted: () => _removeTimeSlot(time),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFFDBEAFE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Time picker button + pending confirmation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Pending time display + actions
              if (_pendingTime != null) ...[
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFF0256C2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTimeDisplay(_pendingTime!),
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Horario por agregar',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _pendingTime = null),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: _confirmPendingTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
                const Divider(height: 24),
              ],
              // Select time button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(_pendingTime != null ? 'Cambiar hora' : 'Seleccionar hora'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0256C2),
                    side: BorderSide(
                      color: const Color(0xFF0256C2).withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _timeSlots.isEmpty
              ? 'Toca "Seleccionar hora" para elegir un horario de atención.'
              : 'Se repite cada semana en los horarios agregados.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }

  String _formatTimeDisplay(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $period';
  }

  Widget _buildMeetingTypeSelector() {
    return Column(
      children: [
        _buildRadioCard(
          title: 'Virtual',
          subtitle: 'Teleconsulta / videollamada.',
          value: 'VIRTUAL',
          groupValue: _meetingType,
          onChanged: (v) {
            if (v != null) setState(() => _meetingType = v);
          },
        ),
        const SizedBox(height: 8),
        _buildRadioCard(
          title: 'Presencial',
          subtitle: 'Atención en consultorio o clínica.',
          value: 'IN_PERSON',
          groupValue: _meetingType,
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _meetingType = v;
                if (v == 'VIRTUAL') _selectedPlace = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return BlocBuilder<PlacesCubit, PlacesState>(
      builder: (context, state) {
        List<PlaceModel> places = [];
        if (state is PlacesLoaded) {
          places = state.places;
        }

        if (places.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No tienes lugares registrados. Crea uno en "Lugares de Atención".',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: places.map((place) {
            final selected = _selectedPlace?.id == place.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlace = place),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? const Color(0xFF0256C2) : const Color(0xFFE2E8F0),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF0256C2) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: selected ? Colors.white : const Color(0xFF0256C2),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            if (place.address != null || place.locationLabel.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  place.address ?? place.locationLabel,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: place.id,
                        // ignore: deprecated_member_use
                        groupValue: _selectedPlace?.id,
                        // ignore: deprecated_member_use
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedPlace = place);
                          }
                        },
                        activeColor: const Color(0xFF0256C2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
