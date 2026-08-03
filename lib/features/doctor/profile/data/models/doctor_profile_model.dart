/// Especialidad del catálogo asignada al profesional.
class DoctorSpecialty {
  final String id;
  final String name;
  final String? professionName;

  const DoctorSpecialty({
    required this.id,
    required this.name,
    this.professionName,
  });

  factory DoctorSpecialty.fromJson(Map<String, dynamic> json) {
    final profession = json['profession'];
    return DoctorSpecialty(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      professionName: profession is Map
          ? profession['name']?.toString()
          : null,
    );
  }
}

/// Profesión (carrera de salud) del profesional.
class DoctorProfession {
  final String id;
  final String name;

  const DoctorProfession({
    required this.id,
    required this.name,
  });

  factory DoctorProfession.fromJson(Map<String, dynamic> json) {
    return DoctorProfession(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

/// Perfil del profesional autenticado.
/// Endpoint: GET /users/me/professional-profile
class DoctorProfileModel {
  final String id;
  final String email;
  final String role;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? documentId;
  final String? documentType;
  final String? phone;
  final String? profilePhotoUrl;
  final bool profileComplete;
  final String? bio;
  final double? rating;
  final List<DoctorSpecialty> specialties;
  final List<DoctorProfession> professions;

  const DoctorProfileModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.firstName,
    this.lastName,
    this.documentId,
    this.documentType,
    this.phone,
    this.profilePhotoUrl,
    required this.profileComplete,
    this.bio,
    this.rating,
    this.specialties = const [],
    this.professions = const [],
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return name.isNotEmpty ? name : 'Profesional de salud';
  }

  String? get primarySpecialty =>
      specialties.isNotEmpty ? specialties.first.name : null;

  int get completionPercent {
    var completed = 0;
    if (bio != null && bio!.trim().isNotEmpty) completed++;
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) completed++;
    if (phone != null && phone!.trim().isNotEmpty) completed++;
    if (specialties.isNotEmpty) completed++;
    return (completed / 4 * 100).round();
  }

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final professional = json['professionalProfile'];
    Map<String, dynamic> professionalJson;
    if (professional is Map) {
      professionalJson = Map<String, dynamic>.from(professional);
    } else {
      professionalJson = <String, dynamic>{};
    }

    final specialtiesJson = professionalJson['specialties'];
    final professionsJson = professionalJson['professions'];

    return DoctorProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      documentId: json['documentId']?.toString(),
      documentType: json['documentType']?.toString(),
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      profileComplete: json['profileComplete'] == true,
      bio: professionalJson['bio']?.toString(),
      rating: professionalJson['rating'] != null
          ? double.tryParse(professionalJson['rating'].toString())
          : null,
      specialties: specialtiesJson is List
          ? specialtiesJson
                .whereType<Map>()
                .map((e) => DoctorSpecialty.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      professions: professionsJson is List
          ? professionsJson
                .whereType<Map>()
                .map((e) => DoctorProfession.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}
