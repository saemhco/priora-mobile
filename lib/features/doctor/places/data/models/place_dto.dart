import 'package:priora/features/doctor/places/domain/models/place.dart';

/// DTO of a point of care (API serialization).
class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.name,
    this.address,
    this.country,
    this.department,
    this.province,
    this.district,
    this.latitude,
    this.longitude,
  });

  factory PlaceDto.fromJson(Map<String, dynamic> json) {
    return PlaceDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Sin nombre',
      address: json['address'] as String?,
      country: json['country'] as String?,
      department: json['department'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String? ?? json['ubigeo'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String name;
  final String? address;
  final String? country;
  final String? department;
  final String? province;
  final String? district;
  final double? latitude;
  final double? longitude;

  Place toDomain() {
    return Place(
      id: id,
      name: name,
      address: address,
      country: country,
      department: department,
      province: province,
      district: district,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
