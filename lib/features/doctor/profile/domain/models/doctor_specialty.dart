/// Catalogue specialty assigned to the professional (domain entity).
class DoctorSpecialty {
  const DoctorSpecialty({
    required this.id,
    required this.name,
    this.professionName,
  });

  final String id;
  final String name;
  final String? professionName;
}
