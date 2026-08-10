import 'package:priora/features/doctor/places/data/services/places_service.dart';
import 'package:priora/features/doctor/places/domain/interfaces/places_repository.dart';
import 'package:priora/features/doctor/places/domain/models/place.dart';

/// Implementation of the [PlacesRepository] contract using [PlacesService].
/// Map DTOs to domain entities.
class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._service);

  final PlacesService _service;

  @override
  Future<List<Place>> fetchMyPlaces({required String accessToken}) async {
    final dtos = await _service.fetchMyPlaces(accessToken: accessToken);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Place> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final dto = await _service.createPlace(
      accessToken: accessToken,
      data: data,
    );
    return dto.toDomain();
  }

  @override
  Future<Place> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  }) async {
    final dto = await _service.updatePlace(
      accessToken: accessToken,
      placeId: placeId,
      data: data,
    );
    return dto.toDomain();
  }

  @override
  Future<void> deletePlace({
    required String accessToken,
    required String placeId,
  }) async {
    await _service.deletePlace(accessToken: accessToken, placeId: placeId);
  }
}
