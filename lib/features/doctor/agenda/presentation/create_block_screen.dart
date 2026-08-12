import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/agenda/presentation/controller/create_block_controller.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_days_selector.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_location_selector.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_meeting_type_selector.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_section_label.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_time_slots_input.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/create_block/create_block_validity_selector.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Screen to create an availability block. Just compose the widget tree; the
/// state and logic live in [CreateBlockController].
class CreateBlockScreen extends StatefulWidget {
  const CreateBlockScreen({super.key});

  @override
  State<CreateBlockScreen> createState() => _CreateBlockScreenState();
}

class _CreateBlockScreenState extends State<CreateBlockScreen> {
  late final CreateBlockController _controller;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    final accessToken = authState is AuthAuthenticated
        ? authState.accessToken
        : '';
    _controller = CreateBlockController(
      repository: getIt<AgendaRepository>(),
      placesCubit: getIt<PlacesCubit>(),
      accessToken: accessToken,
    );
    _controller.loadPlaces();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final error = await _controller.save();
    if (!mounted) return;

    if (error != null) {
      _showError(error);

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bloque creado exitosamente'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
    context.pop(true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return BlocProvider<PlacesCubit>.value(
          value: getIt<PlacesCubit>(),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF1E293B),
                  size: 24,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                    const CreateBlockSectionLabel(text: 'DÍAS DE LA SEMANA'),
                    const SizedBox(height: 10),
                    CreateBlockDaysSelector(controller: _controller),
                    const SizedBox(height: 6),
                    const Text(
                      'Se repite cada semana en los días seleccionados.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    const SizedBox(height: 24),

                    // Validity
                    const CreateBlockSectionLabel(text: 'VIGENCIA'),
                    const SizedBox(height: 10),
                    CreateBlockValiditySelector(controller: _controller),
                    const SizedBox(height: 24),

                    // Time slots
                    const CreateBlockSectionLabel(text: 'HORARIOS'),
                    const SizedBox(height: 10),
                    CreateBlockTimeSlotsInput(controller: _controller),
                    const SizedBox(height: 24),

                    // Meeting type
                    const CreateBlockSectionLabel(text: 'TIPO DE ATENCIÓN'),
                    const SizedBox(height: 10),
                    CreateBlockMeetingTypeSelector(controller: _controller),
                    const SizedBox(height: 24),

                    // Location (only for IN_PERSON)
                    if (_controller.meetingType == 'IN_PERSON') ...[
                      const CreateBlockSectionLabel(text: 'LUGAR DE ATENCIÓN'),
                      const SizedBox(height: 10),
                      CreateBlockLocationSelector(controller: _controller),
                      const SizedBox(height: 24),
                    ],

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _controller.isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0256C2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: _controller.isLoading
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
      },
    );
  }
}
