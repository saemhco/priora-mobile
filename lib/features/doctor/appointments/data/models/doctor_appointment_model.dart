class DoctorAppointmentPatient {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? profilePhotoUrl;

  const DoctorAppointmentPatient({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName {
    if (firstName != null && lastName != null) return '$firstName $lastName';
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return 'Paciente';
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  factory DoctorAppointmentPatient.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentPatient(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['name'] as String?,
      lastName: json['lastName'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}

class DoctorAppointment {
  final String id;
  final DoctorAppointmentPatient patient;
  final String datetime; // ISO string
  final String meetingType; // VIRTUAL | IN_PERSON
  final String? placeName;
  final String status; // PENDING | CONFIRMED | COMPLETED | CANCELED
  final String? specialty;
  final String? triageSessionId;
  final String createdAt;

  const DoctorAppointment({
    required this.id,
    required this.patient,
    required this.datetime,
    required this.meetingType,
    this.placeName,
    required this.status,
    this.specialty,
    this.triageSessionId,
    required this.createdAt,
  });

  bool get isVirtual => meetingType == 'VIRTUAL';

  DateTime get dateTimeObj => DateTime.parse(datetime);

  String get formattedTime {
    final dt = dateTimeObj;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final dt = dateTimeObj;
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String get statusLabel {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirmada';
      case 'PENDING':
        return 'Pendiente';
      case 'COMPLETED':
        return 'Completada';
      case 'CANCELED':
        return 'Cancelada';
      default:
        return status;
    }
  }

  bool get isPast {
    return dateTimeObj.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    final apptDate = dateTimeObj;
    return apptDate.year == now.year &&
        apptDate.month == now.month &&
        apptDate.day == now.day;
  }

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    // Parse patient data - could be at root level or nested
    DoctorAppointmentPatient patient;
    if (json['patient'] != null) {
      patient = DoctorAppointmentPatient.fromJson(
        json['patient'] as Map<String, dynamic>,
      );
    } else {
      // Try to build from root fields
      patient = DoctorAppointmentPatient(
        id: json['patientId'] as String? ?? '',
        firstName: json['patientFirstName'] as String?,
        lastName: json['patientLastName'] as String?,
        profilePhotoUrl: json['patientPhotoUrl'] as String?,
      );
    }

    // Parse place info
    String? placeName;
    if (json['place'] != null) {
      final place = json['place'] as Map<String, dynamic>;
      placeName = place['name'] as String?;
    } else {
      placeName = json['placeName'] as String?;
    }

    return DoctorAppointment(
      id: json['id'] as String? ?? '',
      patient: patient,
      datetime: json['datetime'] as String? ?? '',
      meetingType: json['meetingType'] as String? ?? 'VIRTUAL',
      placeName: placeName,
      status: json['status'] as String? ?? 'PENDING',
      specialty: json['specialty'] as String?,
      triageSessionId: json['triageSessionId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient,
      'datetime': datetime,
      'meetingType': meetingType,
      'placeName': placeName,
      'status': status,
      'specialty': specialty,
      'triageSessionId': triageSessionId,
      'createdAt': createdAt,
    };
  }
}
