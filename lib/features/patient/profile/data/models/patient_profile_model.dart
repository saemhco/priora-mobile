class PatientProfileModel {
  final String id;
  final String email;
  final String role;
  final String name;
  final String firstName;
  final String lastName;
  final String? documentId;
  final String? documentType;
  final String? phone;
  final String? profilePhotoUrl;
  final String? dateOfBirth;
  final String? biologicalSex;
  final String? genderIdentity;
  final String? genderIdentityOther;
  final String? occupation;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool profileComplete;

  PatientProfileModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.documentId,
    this.documentType,
    this.phone,
    this.profilePhotoUrl,
    this.dateOfBirth,
    this.biologicalSex,
    this.genderIdentity,
    this.genderIdentityOther,
    this.occupation,
    this.latitude,
    this.longitude,
    this.description,
    required this.profileComplete,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      documentId: json['documentId']?.toString(),
      documentType: json['documentType']?.toString(),
      phone: json['phone']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      biologicalSex: json['biologicalSex']?.toString(),
      genderIdentity: json['genderIdentity']?.toString(),
      genderIdentityOther: json['genderIdentityOther']?.toString(),
      occupation: json['occupation']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      description: json['description']?.toString(),
      profileComplete: json['profileComplete'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'documentId': documentId,
      'documentType': documentType,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'dateOfBirth': dateOfBirth,
      'biologicalSex': biologicalSex,
      'genderIdentity': genderIdentity,
      'genderIdentityOther': genderIdentityOther,
      'occupation': occupation,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'profileComplete': profileComplete,
    };
  }
}
