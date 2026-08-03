import 'package:priora/features/doctor/places/data/models/place_model.dart';

abstract class PlacesState {
  const PlacesState();
}

class PlacesInitial extends PlacesState {
  const PlacesInitial();
}

class PlacesLoading extends PlacesState {
  const PlacesLoading();
}

class PlacesLoaded extends PlacesState {
  final List<PlaceModel> places;

  const PlacesLoaded(this.places);
}

class PlacesError extends PlacesState {
  final String message;

  const PlacesError(this.message);
}
