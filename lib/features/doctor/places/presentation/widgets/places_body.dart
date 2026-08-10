import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_state.dart';
import 'package:priora/features/doctor/places/presentation/widgets/add_place_card.dart';
import 'package:priora/features/doctor/places/presentation/widgets/place_card.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

/// Body of the places screen: loading/error/list states with pull-to-refresh,
/// editing and deletion.
class PlacesBody extends StatefulWidget {
  const PlacesBody({super.key});

  @override
  State<PlacesBody> createState() => _PlacesBodyState();
}

class _PlacesBodyState extends State<PlacesBody> {
  Future<void> _loadPlaces() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await context.read<PlacesCubit>().loadPlaces(
        accessToken: authState.accessToken,
      );
    }
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
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
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
            backgroundColor: success
                ? const Color(0xFF0D9488)
                : const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          final token = authState is AuthAuthenticated
              ? authState.accessToken
              : '';
          final isTokenValid = token.isNotEmpty;

          return RefreshIndicator(
            onRefresh: _loadPlaces,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...state.places.map(
                  (place) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PlaceCard(
                      place: place,
                      onEdit: () async {
                        final result = await context.push<bool>(
                          '/create-place',
                          extra: place,
                        );
                        if (result == true && mounted) {
                          await _loadPlaces();
                        }
                      },
                      onDelete: isTokenValid
                          ? () => _confirmDelete(place.id, token)
                          : null,
                    ),
                  ),
                ),
                AddPlaceCard(
                  onTap: () async {
                    final result = await context.push<bool>('/create-place');
                    if (result == true && mounted) {
                      await _loadPlaces();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
