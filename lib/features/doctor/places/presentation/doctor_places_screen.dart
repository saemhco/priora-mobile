import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/places/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/controller/places_state.dart';
import 'package:priora/features/doctor/places/presentation/widgets/add_place_card.dart';
import 'package:priora/features/doctor/places/presentation/widgets/place_card.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';

class DoctorPlacesScreen extends StatefulWidget {
  const DoctorPlacesScreen({super.key});

  @override
  State<DoctorPlacesScreen> createState() => _DoctorPlacesScreenState();
}

class _DoctorPlacesScreenState extends State<DoctorPlacesScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PlacesCubit>().loadPlaces(
            accessToken: authState.accessToken,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lugares de Atención',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gestiona tus consultorios y clínicas.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push<bool>('/create-place');
                      if (result == true && mounted) {
                        _loadPlaces();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir lugar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0256C2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<PlacesCubit, PlacesState>(
      builder: (context, state) {
        if (state is PlacesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PlacesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadPlaces,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is PlacesLoaded) {
          final authState = context.read<AuthBloc>().state;
          final token = authState is AuthAuthenticated ? authState.accessToken : '';
          final isTokenValid = token.isNotEmpty;

          return RefreshIndicator(
            onRefresh: _loadPlaces,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...state.places.map((place) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PlaceCard(
                    place: place,
                    onEdit: () async {
                      final result = await context.push<bool>(
                        '/create-place',
                        extra: place,
                      );
                      if (result == true && mounted) {
                        _loadPlaces();
                      }
                    },
                    onDelete: isTokenValid
                        ? () => _confirmDelete(place.id, token)
                        : null,
                  ),
                )),
                  AddPlaceCard(onTap: () async {
                    final result = await context.push<bool>('/create-place');
                    if (result == true && mounted) {
                      _loadPlaces();
                    }
                  }),
                const SizedBox(height: 24),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _confirmDelete(String placeId, String accessToken) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: const Text('¿Estás seguro de eliminar este lugar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<PlacesCubit>().deletePlace(
            accessToken: accessToken,
            placeId: placeId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Lugar eliminado correctamente'
                  : 'Error al eliminar el lugar. Intente nuevamente.',
            ),
            backgroundColor: success ? const Color(0xFF0D9488) : const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
