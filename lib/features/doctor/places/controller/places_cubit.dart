import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/places/controller/places_state.dart';
import 'package:priora/features/doctor/places/data/places_repository.dart';

class PlacesCubit extends Cubit<PlacesState> {
  final PlacesRepository _repository;

  PlacesCubit(this._repository) : super(const PlacesInitial());

  Future<void> loadPlaces({required String accessToken}) async {
    emit(const PlacesLoading());

    try {
      final places = await _repository.fetchMyPlaces(accessToken: accessToken);
      emit(PlacesLoaded(places));
    } catch (e) {
      emit(PlacesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final place = await _repository.createPlace(
        accessToken: accessToken,
        data: data,
      );
      final currentState = state;
      if (currentState is PlacesLoaded) {
        final updatedPlaces = [...currentState.places, place];
        emit(PlacesLoaded(updatedPlaces));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final updated = await _repository.updatePlace(
        accessToken: accessToken,
        placeId: placeId,
        data: data,
      );
      final currentState = state;
      if (currentState is PlacesLoaded) {
        final updatedPlaces = currentState.places.map((p) {
          return p.id == placeId ? updated : p;
        }).toList();
        emit(PlacesLoaded(updatedPlaces));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePlace({
    required String accessToken,
    required String placeId,
  }) async {
    try {
      await _repository.deletePlace(accessToken: accessToken, placeId: placeId);
      final currentState = state;
      if (currentState is PlacesLoaded) {
        final updatedPlaces =
            currentState.places.where((p) => p.id != placeId).toList();
        emit(PlacesLoaded(updatedPlaces));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is PlacesError) {
      emit(const PlacesInitial());
    }
  }
}
