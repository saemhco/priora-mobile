import 'package:priora/features/doctor/places/domain/models/place.dart';

/// Contract for access to the doctor's places of care. The presentation layer
/// depends solely on this abstraction; the implementation lives in
/// `data/repositories/`.
abstract interface class PlacesRepository {
  /// Obtiene los lugares del doctor autenticado.
  Future<List<Place>> fetchMyPlaces({required String accessToken});

  /// Create a place of attention.
  Future<Place> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  });

  /// Update a spot of attention.
  Future<Place> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  });

  /// Remove a place of attention.
  Future<void> deletePlace({
    required String accessToken,
    required String placeId,
  });
}
