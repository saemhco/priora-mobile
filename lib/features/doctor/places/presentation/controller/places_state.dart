import 'package:priora/features/doctor/places/domain/models/place.dart';

/// States of the cubit of places of care of the doctor.
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
  const PlacesLoaded(this.places);

  final List<Place> places;
}

class PlacesError extends PlacesState {
  const PlacesError(this.message);

  final String message;
}
