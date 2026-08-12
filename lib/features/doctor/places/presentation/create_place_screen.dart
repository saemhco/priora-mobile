import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';
import 'package:priora/features/doctor/places/presentation/controller/create_place_controller.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/widgets/create_place/create_place_action_buttons.dart';
import 'package:priora/features/doctor/places/presentation/widgets/create_place/create_place_banner.dart';
import 'package:priora/features/doctor/places/presentation/widgets/create_place/create_place_form.dart';
import 'package:priora/features/doctor/places/presentation/widgets/create_place/create_place_map_button.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Screen to create/edit a place of attention. It only composes the widget
/// tree; the state and logic live in [CreatePlaceController].
class CreatePlaceScreen extends StatefulWidget {
  const CreatePlaceScreen({super.key, this.place});

  final Place? place;

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CreatePlaceController _controller;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState is AuthAuthenticated
        ? authState.accessToken
        : '';
    _controller = CreatePlaceController(
      placesCubit: getIt<PlacesCubit>(),
      accessToken: accessToken,
      place: widget.place,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final success = await _controller.save();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.isEditing
                ? 'Lugar actualizado exitosamente'
                : 'Lugar creado exitosamente',
          ),
        ),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el lugar. Intente nuevamente.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlacesCubit>.value(
      value: getIt<PlacesCubit>(),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final isEditing = _controller.isEditing;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'Editar lugar de atención'
                                : 'Nuevo lugar de atención',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing
                                ? 'Modifica los datos del centro médico o consultorio.'
                                : 'Complete los datos para registrar un nuevo centro médico o consultorio.',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CreatePlaceBanner(isEditing: isEditing),
                    const SizedBox(height: 24),
                    CreatePlaceForm(
                      controller: _controller,
                      formKey: _formKey,
                    ),
                    const SizedBox(height: 24),
                    CreatePlaceMapButton(controller: _controller),
                    const SizedBox(height: 32),
                    CreatePlaceActionButtons(
                      controller: _controller,
                      onSave: _handleSave,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
