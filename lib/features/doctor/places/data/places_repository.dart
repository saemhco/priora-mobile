import 'package:priora/features/doctor/places/data/models/place_model.dart';
import 'package:priora/features/doctor/places/data/places_service.dart';

class PlacesRepository {
  final PlacesService _service;

  PlacesRepository(this._service);

  Future<List<PlaceModel>> fetchMyPlaces({required String accessToken}) async {
    final rawList = await _service.fetchMyPlaces(accessToken: accessToken);
    return rawList
        .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PlaceModel> createPlace({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final raw = await _service.createPlace(accessToken: accessToken, data: data);
    return PlaceModel.fromJson(raw);
  }

  Future<PlaceModel> updatePlace({
    required String accessToken,
    required String placeId,
    required Map<String, dynamic> data,
  }) async {
    final raw = await _service.updatePlace(
      accessToken: accessToken,
      placeId: placeId,
      data: data,
    );
    return PlaceModel.fromJson(raw);
  }

  Future<void> deletePlace({
    required String accessToken,
    required String placeId,
  }) async {
    await _service.deletePlace(accessToken: accessToken, placeId: placeId);
  }
}
