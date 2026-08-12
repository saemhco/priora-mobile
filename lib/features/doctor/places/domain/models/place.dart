/// Doctor's place of care (domain entity, independent of the API).
class Place {
  const Place({
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

  final String id;
  final String name;
  final String? address;
  final String? country;
  final String? department;
  final String? province;
  final String? district;
  final double? latitude;
  final double? longitude;

  String get locationLabel {
    if (district != null) return district!;
    if (province != null) return province!;
    if (department != null) return department!;
    return address ?? 'Sin ubicación';
  }
}
