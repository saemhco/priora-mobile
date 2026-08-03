class PlaceModel {
  final String id;
  final String name;
  final String? address;
  final String? country;
  final String? department;
  final String? province;
  final String? district;
  final double? latitude;
  final double? longitude;

  const PlaceModel({
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

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
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

  String get locationLabel {
    if (district != null) return district!;
    if (province != null) return province!;
    if (department != null) return department!;
    return address ?? 'Sin ubicación';
  }
}
